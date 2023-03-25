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
        return tidepoolClient.api.session?.email ?? "Unknown"
    }

    func logout() {
        tidepoolClient.api.logout { error in
            DispatchQueue.main.async {
                self.showLogin = true
            }
        }
    }

    init(tidepoolClient: TidepoolClient = TidepoolClient()) {
        self.tidepoolClient = tidepoolClient
        self.showLogin = !tidepoolClient.hasSession
        accounts = []
    }

}


extension SummaryViewModel: TLoginSignupDelegate {
    func loginSignupDidComplete(completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.async {
            self.showLogin = false
            completion(nil)
        }
    }

    func loginSignupCancelled() {
        print("Error signup canceled.")
    }
}

