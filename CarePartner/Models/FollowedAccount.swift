//
//  FollowedAccount.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//

import Foundation
import HealthKit

struct FollowedAccount {
    let name: String
    let currentBG: HKQuantity?
    let lastRefresh: Date?
    let basalRate: HKQuantity?
}


extension FollowedAccount {
    static var mock: FollowedAccount {
        return FollowedAccount(name: "Sally", currentBG: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 100), lastRefresh: Date(), basalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 0.45))
    }
}
