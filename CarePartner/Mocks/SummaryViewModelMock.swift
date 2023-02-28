//
//  SummaryViewModelMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//

import Foundation

class SummaryViewModelMock: SummaryViewModel {
    init(tidepoolClient: TidepoolClient = TidepoolClient(), accounts: [FollowedAccount]) {
        super.init(tidepoolClient: tidepoolClient)
        self.showLogin = false
        self.accounts = accounts
    }
}
