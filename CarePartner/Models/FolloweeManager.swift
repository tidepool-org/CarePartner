//
//  SummaryViewModel.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import Combine

@MainActor
class FolloweeManager: ObservableObject {

    private let tidepoolClient: TidepoolClient

    @Published var followees: [String: Followee]

    var cancellable : AnyCancellable?

    init(client: TidepoolClient) {
        tidepoolClient = client
        followees = [:]

        // When account changes, refresh list
        cancellable = client.$session.sink { [weak self] _ in
            Task {
                await self?.refreshFollowees()
            }
        }
    }

    public func refreshFollowees() async {
        do {
            if tidepoolClient.hasSession {
                let users = try await tidepoolClient.api.getUsers()
                let followedUserIds = users.map { $0.userid }

                // Remove unfollowed accounts
                for followee in followees.keys {
                    if !followedUserIds.contains(followee) {
                        followees[followee] = nil
                    }
                }

                // Add newly followed accounts
                for user in users {
                    if !followees.keys.contains(user.userid) {
                        addFollowee(user: user)
                    }
                }
                
                // Refresh all accounts
                await fetchFolloweeData()
            }
        } catch {
            print("Could not get users: \(error)")
        }
    }

    private func fetchFolloweeData() async {
        for followee in followees.values {
            Task {
                await followee.fetchRemoteData(api: tidepoolClient.api)
            }
        }
    }

    private func followeeFromUser(user: TTrusteeUser) -> Followee? {
        guard let profile = user.profile, let fullName = profile.fullName, user.trustorPermissions?.view != nil else {
            return nil
        }
        let firstName = fullName.components(separatedBy: " ").first ?? fullName
        return Followee(name: firstName, userId: user.userid, basalRate: nil)
    }

    private func addFollowee(user: TTrusteeUser) {
        if let followee = followeeFromUser(user: user) {
            followees[user.userid] = followee
        }
    }
}