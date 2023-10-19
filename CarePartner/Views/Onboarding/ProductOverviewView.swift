//
//  ProductOverviewView.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/17/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct ProductOverviewView: View {
    var body: some View {
        OnboardingContent(Text("Welcome to Tidepool Care Partner")) {
            Text("Tidepool Care Partner lets you follow the activity of someone you care for with diabetes. Take a moment to learn about the key features of the app.")
            
            Text("Data Activity")
                .font(.title3.bold())
            
            Text("When a Tidepool Loop user shares their data with you, you will see their:")
            
            BulletList {
                Bullet("Tidepool Loop status")
                Bullet("Glucose Reading")
                Bullet("Glucose Trend Arrow")
                Bullet("Change in Glucose")
                Bullet("Basal Rate")
                Bullet("Active Insulin & Active Carbs")
            }
            
            Image("onboarding-product-overview")
                .onboardingFullWidth()
            
            Text("Notifications")
                .font(.title3.bold())
            
            Text("You will also receive notifications informing you of important changes to insulin and glucose levels. These notifications will be pre-configured by the Tidepool Loop user, but you may make adjustments at anytime in your Settings. You will receive the following:")
            
            BulletList {
                Bullet("Urgent Low")
                Bullet("Low")
                Bullet("High")
                Bullet("Loop Not Looping")
                Bullet("No Communication")
            }
        } onboardingLink: {
            OnboardingLink(.continue, destination: .claimsConfirmation)
        }
    }
}

struct ProductOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductOverviewView()
        }
        .environmentObject(OnboardingViewModel())
    }
}
