//
//  FolloweeManagerMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

class FolloweeManagerMock: FolloweeManager {
    init(followees: [FolloweeStatus], pendingInviteUserDetails: [UserDetails] = []) {
        super.init(client: TidepoolClient.loggedInMock)

        for status in followees {
            self.followees[status.firstName] = FolloweeMock(status: status)
        }
        
        self.pendingInviteUserDetails = pendingInviteUserDetails
    }

    override func refreshFollowees() async {
        await fetchFolloweeData()
    }
}
