//
//  FolloweeStatus.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/26/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import HealthKit
import LoopKit

struct FolloweeStatus {
    var name: String
    var latestGlucose: GlucoseSampleValue?
    var trend: GlucoseTrend?
    var lastRefresh: Date?
    var basalRate: HKQuantity?
}

extension FolloweeStatus {
    static var mock: FolloweeStatus {
        return FolloweeStatus(
            name: "Sally",
            latestGlucose: StoredGlucoseSample.mock(),
            lastRefresh: Date(),
            basalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 0.45))
    }
}

extension StoredGlucoseSample {
    static func mock(_ glucose: Double = 100, _ trend: GlucoseTrend = .flat) -> StoredGlucoseSample {
        return StoredGlucoseSample(
            uuid: UUID(),
            provenanceIdentifier: "org.loopkit.Loop",
            syncIdentifier: "mock-identifier",
            syncVersion: 1,
            startDate: Date(),
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: glucose),
            condition: .none,
            trend: trend,
            trendRate: HKQuantity(unit: .milligramsPerDeciliter.unitDivided(by: .minute()), doubleValue: 1),
            isDisplayOnly: false,
            wasUserEntered: false,
            device: nil,
            healthKitEligibleDate: nil)
    }
}
