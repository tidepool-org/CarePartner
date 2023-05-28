//
//  Followee+Mock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/28/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

extension Followee {
    static var mock: Followee {
        return Followee(name: "test", userId: "1234", currentBG: nil, lastRefresh: nil, basalRate: nil)
    }
}
