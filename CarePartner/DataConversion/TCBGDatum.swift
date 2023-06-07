//
//  TCBGDatum.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/31/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import TidepoolKit
import HealthKit
import LoopKit


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
