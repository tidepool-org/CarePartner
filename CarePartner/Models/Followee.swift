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


class Followee: ObservableObject, Identifiable {

    @Published var status: FolloweeStatus

    let name: String
    let userId: String
    let lastRefresh: Date?
    let basalRate: HKQuantity?
    let glucoseStore: GlucoseStore
    private let log = OSLog(category: "Followee")
    var cancellables: Set<AnyCancellable> = []


    init(name: String, userId: String, lastRefresh: Date?, basalRate: HKQuantity?) {
        self.name = name
        self.userId = userId
        self.lastRefresh = lastRefresh
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
            latestGlucose: latestGlucose,
            trend: latestGlucose?.trend,
            lastRefresh: lastRefresh ?? .distantPast,
            basalRate: basalRate)

        NotificationCenter.default.publisher(for: GlucoseStore.glucoseSamplesDidChange, object: nil)
            .receive(on: RunLoop.main)
            .sink() { [weak self] _ in
                self?.status.latestGlucose = self?.glucoseStore.latestGlucose
            }
            .store(in: &cancellables)
    }


    func fetchData(api: TAPI) async {
        let start = Date().addingTimeInterval(-.days(1))
        let filter = TDatum.Filter(startDate: start, types: ["cbg"])
        do {
            let (data, _) = try await api.listData(filter: filter, userId: userId)

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
