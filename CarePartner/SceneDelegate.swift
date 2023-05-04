//
//  SceneDelegate.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/2/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import UIKit
import AuthenticationServices


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
