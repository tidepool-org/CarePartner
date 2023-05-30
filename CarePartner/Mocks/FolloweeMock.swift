//
//  FolloweeMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/30/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

class FolloweeMock: Followee {

    init(status: FolloweeStatus) {
        super.init(name: "Mock", userId: "1234", basalRate: nil)
        self.status = status
    }
}
