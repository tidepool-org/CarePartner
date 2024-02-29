//
//  AppView.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/17/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject private var client: TidepoolClient
    @EnvironmentObject private var followeeManager: FolloweeManager

    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    private let formatters = QuantityFormatters(glucoseUnit: .milligramsPerDeciliter)

    var body: some View {
        NavigationStack {
            FolloweeListView(manager: followeeManager, client: client)
                .fullScreenCover(isPresented: $onboardingViewModel.hasNotCompletedOnboarding) {
                    NavigationStack {
                        ProductOverviewView()
                    }
                }
        }
        .environmentObject(formatters)
        .environmentObject(onboardingViewModel)
    }
}

struct AppView_Previews: PreviewProvider {
    static let client = TidepoolClient()
    static var previews: some View {
        AppView()
            .environmentObject(client)
            .environmentObject(FolloweeManager(client: client))
    }
}
