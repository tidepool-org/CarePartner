//
//  FolloweeManagerMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

class FolloweeManagerMock: FolloweeManager {
    init(followees: [FolloweeStatus], pendingInvites: [PendingInvite] = []) {
        super.init(client: TidepoolClient.loggedInMock)

        for status in followees {
            self.followees[status.firstName] = FolloweeMock(status: status)
        }
        
        for pendingInvite in pendingInvites {
            self.pendingInvites[pendingInvite.userDetails.id] = pendingInvite
        }
    }

    override func refreshFollowees() async {
        await fetchFolloweeData()
    }
}
