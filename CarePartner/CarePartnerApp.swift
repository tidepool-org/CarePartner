//
//  CarePartnerApp.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//

import SwiftUI
import AuthenticationServices

@main
@MainActor
struct CarePartnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let client = TidepoolClient()
    let followedAccounts: FollowedAccounts

    init() {
        followedAccounts = FollowedAccounts(client: client)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                FollowedAccountsView(followedAccounts: followedAccounts, client: client)
            }
        }
    }
}
