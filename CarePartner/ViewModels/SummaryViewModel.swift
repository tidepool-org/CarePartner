//
//  SummaryViewModel.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//

import Foundation
import TidepoolKit

class SummaryViewModel: ObservableObject {

    @Published var showLogin: Bool
    @Published var accounts: [FollowedAccount]

    let tidepoolClient: TidepoolClient

    var accountLogin: String {
        return tidepoolClient.accountLogin ?? "Unknown"
    }

    func logout() async {
        await tidepoolClient.logout()
        showLogin = true
    }

    init(tidepoolClient: TidepoolClient = TidepoolClient()) {
        self.tidepoolClient = tidepoolClient
        self.showLogin = !tidepoolClient.hasSession
        accounts = []

        refreshFollowees()
    }

    func refreshFollowees() {
        tidepoolClient.api.getUsers { result in
            switch result {
            case .failure(let error):
                print("Could not get users: \(error)")
            case.success(let profiles):
                DispatchQueue.main.async {
                    self.accounts = profiles.compactMap { $0.followedAccount }
                }
            }
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


extension SummaryViewModel: TLoginSignupDelegate {
    func loginSignupDidComplete(completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            self.showLogin = false
            completion(nil)
            self.refreshFollowees()
        }
    }

    func loginSignupCancelled() {
        print("Error signup canceled.")
    }
}

