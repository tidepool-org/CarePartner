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
        super.init(name: status.name, userId: status.name)
        self.status = status
    }

    override func refreshGlucose() async {
    }
}
