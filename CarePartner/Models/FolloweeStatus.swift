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

struct BasalDeliveryState {
    var date: Date
    var rate: Double
    var scheduledRate: Double
    var isSuspended: Bool
    var isTempBasal: Bool {
        return rate != scheduledRate && !isSuspended
    }
}

struct FolloweeStatus {
    var name: String
    var lastRefresh: Date
    var latestGlucose: GlucoseSampleValue?
    var glucoseDelta: HKQuantity?
    var trend: GlucoseTrend?
    var activeInsulin: InsulinValue?
    var activeCarbs: CarbValue?
    var basalState: BasalDeliveryState?
    var lastBolusDate: Date?
    var lastCarbDate: Date?
}

extension FolloweeStatus {
    static var mockSally: FolloweeStatus {
        return FolloweeStatus(
            name: "Sally",
            lastRefresh: Date(),
            latestGlucose: StoredGlucoseSample.mock(),
            basalState: BasalDeliveryState(date: Date(), rate: 0.45, scheduledRate: 0.5, isSuspended: false))
    }

    static var mockOmar: FolloweeStatus {
        return FolloweeStatus(
            name: "Omar",
            lastRefresh: Date(),
            latestGlucose: StoredGlucoseSample.mock(),
            basalState: BasalDeliveryState(date: Date(), rate: 0.45, scheduledRate: 0.5, isSuspended: false))
    }

}

extension StoredGlucoseSample {
    static func mock(_ glucose: Double = 100, _ trend: GlucoseTrend = .flat) -> StoredGlucoseSample {
        return StoredGlucoseSample(
            uuid: UUID(),
            provenanceIdentifier: "org.loopkit.Loop",
            syncIdentifier: "mock-identifier",
            syncVersion: 1,
            startDate: Date().addingTimeInterval(-4 * 60),
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
