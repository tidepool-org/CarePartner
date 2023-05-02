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


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

class SceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate, ASWebAuthenticationPresentationContextProviding {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = windowScene.keyWindow
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}
