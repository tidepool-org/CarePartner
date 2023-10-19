//
//  AppView.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/17/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct AppView: View {

    @StateObject private var onboardingViewModel: OnboardingViewModel
    
    private let client: TidepoolClient
    private let followedAccounts: FolloweeManager
    private let formatters = QuantityFormatters(glucoseUnit: .milligramsPerDeciliter)

    @MainActor
    init() {
        _onboardingViewModel = StateObject(wrappedValue: OnboardingViewModel())
        client = TidepoolClient()
        followedAccounts = FolloweeManager(client: client)
    }

    var body: some View {
        NavigationStack {
            FolloweeListView(manager: followedAccounts, client: client)
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
    static var previews: some View {
        AppView()
    }
}
