//
//  NotificationsView.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/17/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct NotificationsView: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingContent(Text("Notifications")) {
            Text("Enable iOS Notifications")
                .font(.title3.bold())
            
            Text("To allow Tidepool Care Partner to alert you with important information about highs and lows, you will need to enable notifications in your iOS settings. The app will prompt you to allow notifications next, once you click continue.")
            
            Text("Time Sensitive Notifications")
                .font(.title3.bold())
            
            Text("Tidepool Care Partner will send you Time Sensitive alerts. These alerts are a type of Apple notification and are designed to alert you to higher risk situations, such as urgent low glucose, insulin pump occlusions, or other serious system errors.")
            
            Image("onboarding-notifications")
                .onboardingFullWidth()
        } onboardingLink: {
            OnboardingLink(
                .continue,
                destination: .managingFocusModes
            ) {
                await onboardingViewModel.requestAuthorization()
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationsView()
        }
    }
}
