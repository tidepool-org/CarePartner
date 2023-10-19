//
//  ManagingFocusModesView.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/17/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct ManagingFocusModesView: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingContent(Text("Focus Modes")) {
            Text("Using Focus Modes with Tidepool Care Partner")
                .font(.title3.bold())
            
            Text("iOS 15 has added features such as ‘Focus Modes’ that enable you to have more control over when all your apps can send you notifications.")
            
            Text("If you wish to continue receiving important notifications from Tidepool Care Partner while in a Focus Mode, you must add this app as an ‘Allowed App’ for each Focus Mode.")
            
            BulletList(.incrementing) {
                Bullet("Go to Settings > Focus.")
                Bullet("Tap a provided Focus option — like Do Not Disturb, Personal, or Sleep.")
                Bullet("Under Allowed Notifications, tap “Apps”.")
                Bullet("Tap “Add App” and add Tidepool Care Partner.")
                Bullet("Ensure that “Time Sensitive” is toggled ON.")
            }
        } onboardingLink: {
            OnboardingLink(.finish) {
                onboardingViewModel.hasNotCompletedOnboarding = false
            }
        }
    }
}

struct ManagingFocusModesView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var onboardingViewModel = OnboardingViewModel()
        
        var body: some View {
            Color.white
                .fullScreenCover(isPresented: $onboardingViewModel.hasNotCompletedOnboarding) {
                    NavigationStack {
                        ManagingFocusModesView()
                    }
                }
                .environmentObject(onboardingViewModel)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
