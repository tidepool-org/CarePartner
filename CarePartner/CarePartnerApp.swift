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
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appDelegate.client)
                .environmentObject(appDelegate.followeeManager)
        }
    }
}
