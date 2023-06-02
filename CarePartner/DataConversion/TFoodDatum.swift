//
//  TFoodDatum.swift
//  CarePartner
//
//  Created by Pete Schwamb on 6/2/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import TidepoolKit
import HealthKit
import LoopKit


extension TFoodDatum {
    var syncCarbObject: SyncCarbObject? {
        guard let time, let nutrition else { return nil }

        guard let carbohydrate = nutrition.carbohydrate, let units = carbohydrate.units, units == .grams, let amount = carbohydrate.net else {
            return nil
        }

        guard let origin, let provenance = origin.name else {
            return nil
        }

        guard let payload, let syncIdentifier = payload.dictionary["syncIdentifier"] as? String else {
            return nil
        }

        var uuid: UUID?
        if let uuidString = payload.dictionary["uuid"] as? String {
            uuid = UUID(uuidString: uuidString)
        }

        var addedDate: Date?
        if let addedDateString = payload.dictionary["addedDate"] as? String {
            addedDate = Date(jsonString: addedDateString)
        }

        var userCreatedDate: Date?
        if let userCreatedDateString = payload.dictionary["userCreatedDate"] as? String {
            userCreatedDate = Date(jsonString: userCreatedDateString)
        }

        var userUpdatedDate: Date?
        if let userUpdatedDateString = payload.dictionary["userUpdatedDate"] as? String {
            userUpdatedDate = Date(jsonString: userUpdatedDateString)
        }

        var userDeletedDate: Date?
        if let userDeletedDateString = payload.dictionary["userDeletedDate"] as? String {
            userDeletedDate = Date(jsonString: userDeletedDateString)
        }

        var supercededDate: Date?
        if let supercededDateString = payload.dictionary["supercededDate"] as? String {
            supercededDate = Date(jsonString: supercededDateString)
        }


        return SyncCarbObject(
            absorptionTime: nutrition.estimatedAbsorptionDuration,
            createdByCurrentApp: false,
            foodType: name,
            grams: amount,
            startDate: time,
            uuid: uuid,
            provenanceIdentifier: provenance,
            syncIdentifier: syncIdentifier,
            syncVersion: payload.dictionary["syncVersion"] as? Int ?? 1,
            userCreatedDate: userCreatedDate,
            userUpdatedDate: userUpdatedDate,
            userDeletedDate: userDeletedDate,
            operation: .create,
            addedDate: addedDate,
            supercededDate: supercededDate)
    }
}
