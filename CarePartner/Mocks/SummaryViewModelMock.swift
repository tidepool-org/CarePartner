//
//  SummaryViewModelMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

class FollowedAccountsMock: FolloweeManager {
    init(accounts: [FolloweeStatus]) {
        super.init(client: TidepoolClient())
        self.followees = [:]
    }
}
