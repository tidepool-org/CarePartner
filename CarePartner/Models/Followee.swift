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

@MainActor
class Followee: ObservableObject, Identifiable {

    @Published var status: FolloweeStatus
    @Published var isLoading: Bool = false

    let name: String
    let userId: String
    let basalRate: HKQuantity?
    let glucoseStore: GlucoseStore
    private let log = OSLog(category: "Followee")
    var cancellables: Set<AnyCancellable> = []


    init(name: String, userId: String, basalRate: HKQuantity?) {
        self.name = name
        self.userId = userId
        self.basalRate = basalRate

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
            lastRefresh: .distantPast,
            basalRate: basalRate)

        NotificationCenter.default.publisher(for: GlucoseStore.glucoseSamplesDidChange, object: nil)
            .receive(on: RunLoop.main)
            .sink() { [weak self] _ in
                self?.refreshGlucose()
            }
            .store(in: &cancellables)

        self.refreshGlucose()
    }

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
        print("******* setting isLoading = true")
        self.isLoading = true
        let start = Date().addingTimeInterval(-.days(1))
        let filter = TDatum.Filter(startDate: start, types: ["cbg"])
        do {
            let (data, _) = try await api.listData(filter: filter, userId: userId)

            status.lastRefresh = Date()

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
        print("******* setting isLoading = false")
        self.isLoading = false
    }
}

extension TBloodGlucose.Units {
    var hkUnit: HKUnit? {
        switch self {
        case .milligramsPerDeciliter:
            return .milligramsPerDeciliter
        case .millimolesPerLiter:
            return .millimolesPerLiter
        }
    }
}

extension TBloodGlucose.Trend {
    var loopKitTrend: GlucoseTrend {
        switch self {
        case .constant:
            return .flat
        case .slowFall:
            return .down
        case .slowRise:
            return .up
        case .moderateFall:
            return .downDown
        case .moderateRise:
            return .upUp
        case .rapidFall:
            return .downDownDown
        case .rapidRise:
            return .upUpUp
        }
    }
}

extension TCBGDatum {
    var newGlucoseSample: NewGlucoseSample? {
        guard let unit = units?.hkUnit, let value = value, let date = time else {
            return nil
        }
        let rate: HKQuantity?
        if let trendRate {
            let rateUnit = unit.unitDivided(by: .minute())
            rate = HKQuantity(unit: rateUnit, doubleValue: trendRate)
        } else {
            rate = nil
        }
        let syncIdentifier: String
        if let payload, let identifier = payload["syncIdentifier"] as? String {
            syncIdentifier = identifier
        } else {
            syncIdentifier = id ?? String(describing: date.timeIntervalSince1970)
        }
        return NewGlucoseSample(
            date: date,
            quantity: HKQuantity(unit: unit, doubleValue: value),
            condition: nil,
            trend: trend?.loopKitTrend,
            trendRate: rate,
            isDisplayOnly: false, wasUserEntered: false,
            syncIdentifier: syncIdentifier)
    }
}
