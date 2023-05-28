//
//  CarePartnerApp.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKitUI
import AuthenticationServices

@main
@MainActor
struct CarePartnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let client = TidepoolClient()
    let followedAccounts: FolloweeManager
    let glucosePreference = DisplayGlucosePreference(displayGlucoseUnit: .milligramsPerDeciliter)

    init() {
        followedAccounts = FolloweeManager(client: client)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                FolloweeListView(manager: followedAccounts, client: client)
                    .environmentObject(glucosePreference)
            }
        }
    }
}
