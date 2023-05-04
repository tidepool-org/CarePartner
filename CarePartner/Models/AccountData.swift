//
//  FollowedAccount.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//

import Foundation
import HealthKit

struct AccountData {
    let name: String
    let userid: String
    let currentBG: HKQuantity?
    let lastRefresh: Date?
    let basalRate: HKQuantity?
}


extension AccountData {
    static var mock: AccountData {
        return AccountData(
            name: "Sally",
            userid: "9138ecc2-ed54-4254-bcc4-687d37d6398b",
            currentBG: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 100),
            lastRefresh: Date(),
            basalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 0.45))
    }
}
