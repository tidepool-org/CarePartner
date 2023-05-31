//
//  FolloweeStatus.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import HealthKit
import LoopKit
import CoreData
import TidepoolKit
import os.log
import Combine

protocol FolloweeDelegate: AnyObject {
    func stateDidChange(for followee: Followee)
}

@MainActor
class Followee: ObservableObject, Identifiable {
    typealias RawValue = [String: Any]

    @Published var status: FolloweeStatus
    @Published var isLoading: Bool = false

    let name: String
    let userId: String
    let glucoseStore: GlucoseStore
    private let log = OSLog(category: "Followee")
    var cancellables: Set<AnyCancellable> = []

    weak var delegate: FolloweeDelegate?

    init(name: String, userId: String, lastRefresh: Date = .distantPast) {
        self.name = name
        self.userId = userId

        let url = NSPersistentContainer.defaultDirectoryURL.appendingPathComponent(userId)
        let cacheStore = PersistenceController(directoryURL: url)
        glucoseStore = GlucoseStore(
            cacheStore: cacheStore,
            provenanceIdentifier: HKSource.default().bundleIdentifier
        )

        let latestGlucose = glucoseStore.latestGlucose

        status = FolloweeStatus(
            name: name,
            latestGlucose: nil,
            trend: latestGlucose?.trend,
            lastRefresh: lastRefresh,
            basalRate: nil)

        NotificationCenter.default.publisher(for: GlucoseStore.glucoseSamplesDidChange, object: nil)
            .receive(on: RunLoop.main)
            .sink() { [weak self] _ in
                self?.refreshGlucose()
            }
            .store(in: &cancellables)

        glucoseStore.onReady { error in
            if error == nil {
                self.refreshGlucose()
            }
        }
    }

    convenience init?(rawValue: [String : Any]) {
        guard let name = rawValue["name"] as? String,
              let userId = rawValue["userId"] as? String
        else { return nil }

        let lastRefresh = rawValue["lastRefresh"] as? Date ?? .distantPast

        self.init(name: name, userId: userId, lastRefresh: lastRefresh)
    }

    var rawValue: [String : Any] {
        return [
            "name": name,
            "userId": userId,
            "lastRefresh": status.lastRefresh
        ]
    }


    // MARK: - Remote data
    func refreshGlucose() {
        if let latest = glucoseStore.latestGlucose, latest.startDate.timeIntervalSinceNow > -.minutes(15) {
            status.latestGlucose = glucoseStore.latestGlucose
            Task {
                do {
                    let samples = try await glucoseStore.getGlucoseSamples(start: latest.startDate.addingTimeInterval(-.minutes(6)))
                    if let previousSample = samples.filter({ $0.syncIdentifier != latest.syncIdentifier }).sorted(by: \.startDate).last {
                        let delta = latest.quantity.doubleValue(for: .milligramsPerDeciliter) - previousSample.quantity.doubleValue(for: .milligramsPerDeciliter)
                        status.glucoseDelta = HKQuantity(unit: .milligramsPerDeciliter, doubleValue: delta)
                    } else {
                        status.glucoseDelta = nil
                    }
                } catch {
                    status.glucoseDelta = nil
                }
            }
        } else {
            status.latestGlucose = nil
            status.glucoseDelta = nil
        }
    }

    func fetchRemoteData(api: TAPI) async {
        self.isLoading = true
        let start = Date().addingTimeInterval(-.days(1))
        let filter = TDatum.Filter(startDate: start, types: ["cbg"])
        do {
            let (data, _) = try await api.listData(filter: filter, userId: userId)

            status.lastRefresh = Date()

            delegate?.stateDidChange(for: self)

            var newSamples = [NewGlucoseSample]()

            for datum in data {
                switch datum {
                case let cbg as TCBGDatum:
                    if let sample = cbg.newGlucoseSample {
                        newSamples.append(sample)
                    }
                default:
                    break
                }
            }
            if !newSamples.isEmpty {
                glucoseStore.addGlucoseSamples(newSamples) { result in }
            }
        } catch {
            log.error("Unable to fetch data for %{public}@: %{public}@", userId, error.localizedDescription)
        }
        self.isLoading = false
    }
}
