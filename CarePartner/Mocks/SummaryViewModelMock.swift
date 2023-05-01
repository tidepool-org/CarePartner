//
//  SummaryViewModelMock.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//

import Foundation

class SummaryViewModelMock: SummaryViewModel {
    init(accounts: [FollowedAccount]) {
        super.init()
        self.accounts = accounts
    }
}
