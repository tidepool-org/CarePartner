//
//  SummaryViewModelMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//

import Foundation

class FollowedAccountsMock: FollowedAccounts {
    init(accounts: [AccountData]) {
        super.init(client: TidepoolClient.loggedInMock)
        self.accounts = accounts
    }
}
