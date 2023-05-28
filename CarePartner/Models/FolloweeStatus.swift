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
    var userId: String
    var latestGlucose: GlucoseSampleValue?
    var trend: GlucoseTrend?
    var lastRefresh: Date?
    var basalRate: HKQuantity?
}

extension FolloweeStatus {
    static var mock: FolloweeStatus {
        return FolloweeStatus(
            name: "Sally",
            userId: "9138ecc2-ed54-4254-bcc4-687d37d6398b",
            latestGlucose: StoredGlucoseSample.mock,
            lastRefresh: Date(),
            basalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 0.45))
    }
}

extension StoredGlucoseSample {
    static var mock: StoredGlucoseSample {
        return StoredGlucoseSample(
            uuid: UUID(),
            provenanceIdentifier: "org.loopkit.Loop",
            syncIdentifier: "mock-identifier",
            syncVersion: 1,
            startDate: Date(),
            quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 100),
            condition: .none,
            trend: .flat,
            trendRate: HKQuantity(unit: .milligramsPerDeciliter.unitDivided(by: .minute()), doubleValue: 1),
            isDisplayOnly: false,
            wasUserEntered: false,
            device: nil,
            healthKitEligibleDate: nil)
    }
}
