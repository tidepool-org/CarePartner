//
//  OnboardingViewModel.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/18/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import OSLog
import SwiftUI
import UserNotifications

class OnboardingViewModel: ObservableObject {
    
    /// Persistent onboarding completion state
    @AppStorage("hasNotCompletedOnboarding") var hasNotCompletedOnboarding = true
    
    private let log = OSLog(category: "OnboardingViewModel")
    
    /// Creates an OnboardingViewModel instance
    /// - Parameter showOnboarding: Set this value to override the `hasNotCompletedOnboarding` value in `@AppStorage`
    init(showOnboarding: Bool? = nil) {
        if let showOnboarding {
            self.hasNotCompletedOnboarding = showOnboarding
        }
    }
    
    /// Request user permission for notification authorization
    func requestNotificationAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .criticalAlert, .carPlay, .sound])
        } catch {
            log.default("Could not request notification authorization:\n\t(%@)", error.localizedDescription)
        }
    }
}
