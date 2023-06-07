//
//  TAutomatedBolusDatum.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/31/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import LoopKit

extension TAutomatedBolusDatum {
    var dose: DoseEntry? {
        guard let time, let normal else { return nil }

        let deliveredUnits: Double?

        let programmedUnits = expectedNormal ?? normal

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

        return DoseEntry(
            type: .bolus,
            startDate: time,
            value: programmedUnits,
            unit: .units,
            deliveredUnits: deliveredUnits,
            syncIdentifier: syncIdentifier,
            insulinType: nil, // TODO
            automatic: true)
    }
}
