//
//  SummaryViewModel.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//

import Foundation
import TidepoolKit
import Combine

@MainActor
class FollowedAccounts: ObservableObject {

    @Published var accounts: [AccountData]

    private let tidepoolClient: TidepoolClient

    var cancellable : AnyCancellable?

    init(client: TidepoolClient) {
        tidepoolClient = client
        accounts = []

        cancellable = client.$session.sink { [weak self] _ in
            Task {
                await self?.refreshFollowees()
            }
        }
    }

    public func refreshFollowees() async {
        do {
            let profiles = try await tidepoolClient.api.getUsers()
            self.accounts = profiles.compactMap { $0.followedAccount }
        } catch {
            self.accounts = []
            print("Could not get users: \(error)")
        }
    }
}

extension TTrusteeUser {
    var followedAccount: AccountData? {
        guard let profile = profile, let fullName = profile.fullName else {
            return nil
        }
        return AccountData(name: fullName, currentBG: nil, lastRefresh: nil, basalRate: nil)
    }
}
