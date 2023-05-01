//
//  SummaryViewModel.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//

import Foundation
import TidepoolKit

@MainActor
class SummaryViewModel: ObservableObject {

    @Published var accounts: [FollowedAccount]

    let tidepoolClient = TidepoolClient()

    init() {
        accounts = []
    }

    public func refreshFollowees() async {
        do {
            let profiles = try await tidepoolClient.api.getUsers()
            self.accounts = profiles.compactMap { $0.followedAccount }
        } catch {
            print("Could not get users: \(error)")
        }
    }
}

extension TTrusteeUser {
    var followedAccount: FollowedAccount? {
        guard let profile = profile, let fullName = profile.fullName else {
            return nil
        }
        return FollowedAccount(name: fullName, currentBG: nil, lastRefresh: nil, basalRate: nil)
    }
}
