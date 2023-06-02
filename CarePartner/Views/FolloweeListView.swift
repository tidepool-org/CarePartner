//
//  FollowedAccountsView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI
import TidepoolKit
import LoopKitUI

struct FolloweeListView: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject private var manager: FolloweeManager
    @ObservedObject private var client: TidepoolClient

    @State private var showingAccountSettings = false

    init(manager: FolloweeManager, client: TidepoolClient) {
        self.manager = manager
        self.client = client
    }

    var body: some View {
        // TODO: list of followed accounts with their summary views
        ScrollView {
            if manager.followees.isEmpty {
                Text("No accounts have shared data with you yet.")
                    .padding(.horizontal)
            } else {
                ForEach(Array(manager.followees.values)) { followee in
                    FolloweeStatusView(followee: followee)
                }
            }
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView(client: client)
        }
        .navigationTitle("Following")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(role: .none, action: {
                showingAccountSettings = true
            }) {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
        .task {
            if !client.hasSession {
                self.showingAccountSettings = true
            }
        }
        .refreshable {
            await manager.refreshFollowees()
            print("Do your refresh work here")
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await manager.refreshFollowees()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FolloweeListView(
                manager: FolloweeManagerMock(
                    followees: [
                        FolloweeStatus.mockSally,
                        FolloweeStatus.mockOmar
                    ]),
                client: TidepoolClient.loggedInMock)
        }
        .environmentObject(QuantityFormatters(glucoseUnit: .milligramsPerDeciliter))
        NavigationView {
            FolloweeListView(
                manager: FolloweeManagerMock(followees: []),
                client: TidepoolClient.loggedInMock)
        }
    }
}
