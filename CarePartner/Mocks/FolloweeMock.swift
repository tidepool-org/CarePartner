//
//  FolloweeMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/30/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

class FolloweeMock: Followee {

    init(status: FolloweeStatus, triggerLoading: Bool = false) {
        super.init(fullName: status.firstName, userId: status.firstName)
        self.status = status

        if triggerLoading {
            mockSlowLoad()
        }
    }

    func mockSlowLoad() {
        DispatchQueue.main.async() {
            self.isLoading = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
        }
    }

    override func refreshGlucose() async {
    }

    override func fetchRemoteData(api: TAPI) async {
        mockSlowLoad()
    }

}
