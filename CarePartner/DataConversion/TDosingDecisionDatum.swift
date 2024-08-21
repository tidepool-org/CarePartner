//
//  TDosingDecisionDatum.swift
//  CarePartner
//
//  Created by Pete Schwamb on 6/1/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import LoopAlgorithm
import LoopKit
import HealthKit

extension TDosingDecisionDatum {
    var storedDosingDecision: StoredDosingDecision? {
        guard let reason else { return nil }

        let insulinValue: InsulinValue?
        if let insulinOnBoard, let startDate = insulinOnBoard.time, let amount = insulinOnBoard.amount {
            insulinValue = InsulinValue(startDate: startDate, value: amount)
        } else {
            insulinValue = nil
        }

        let carbsOnBoard: CarbValue?
        if let carbohydratesOnBoard, let startDate = carbohydratesOnBoard.time, let amount = carbohydratesOnBoard.amount {
            carbsOnBoard = CarbValue(startDate: startDate, value: amount)
        } else {
            carbsOnBoard = nil
        }

        //let pumpManagerStatus: PumpManagerStatus?
        

        //let pumpStatusHighlight: StoredDeviceHighlight?

        return StoredDosingDecision(reason: reason, carbsOnBoard: carbsOnBoard, insulinOnBoard: insulinValue)
    }
}
