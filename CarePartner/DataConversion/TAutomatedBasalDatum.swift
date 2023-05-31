//
//  TAutomatedBasalDatum.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/31/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import LoopKit
import HealthKit

extension TAutomatedBasalDatum {
    var dose: DoseEntry? {
        let endDate: Date?

        guard let time, let rate else { return nil }

        if let duration, duration > 0 {
            endDate = time.addingTimeInterval(duration)
        } else {
            endDate = nil
        }

        let deliveredUnits: Double?

        if let payload {
            deliveredUnits = payload["deliveredUnits"] as? Double
        } else {
            deliveredUnits = nil
        }

        let syncIdentifier: String
        if let payload, let identifier = payload["syncIdentifier"] as? String {
            syncIdentifier = identifier
        } else {
            guard let id else { return nil }
            syncIdentifier = id
        }

        let scheduledBasalRate: HKQuantity?
        if let suppressed = suppressed as? TAutomatedBasalDatum.Suppressed, suppressed.deliveryType == .scheduled, let rate = suppressed.rate {
            scheduledBasalRate = HKQuantity(unit: .internationalUnitsPerHour, doubleValue: rate)
        } else {
            scheduledBasalRate = nil
        }

        return DoseEntry(
            type: .tempBasal,
            startDate: time,
            endDate: endDate,
            value: rate,
            unit: .unitsPerHour,
            deliveredUnits: deliveredUnits,
            syncIdentifier: syncIdentifier,
            scheduledBasalRate: scheduledBasalRate,
            insulinType: nil, // TODO
            automatic: true)
    }
}
