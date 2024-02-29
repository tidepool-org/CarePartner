//
//  AppDelegate.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/2/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import OSLog
import TidepoolKit
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private(set) lazy var client: TidepoolClient = TidepoolClient()
    private(set) lazy var followeeManager: FolloweeManager = FolloweeManager(client: client)
    
    private let log = OSLog(category: "AppDelegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            do {
                try await client.api.registerPushToken(pushToken: deviceToken)
            } catch {
                log.error("Could not get register device token: %{public}@", error.localizedDescription)
            }
        }
    }
}
