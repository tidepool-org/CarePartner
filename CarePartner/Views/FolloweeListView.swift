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
    
    let timer = Timer.publish(every: .minutes(1), on: .main, in: .common).autoconnect()
    
    @State private var showingAccountSettings = false
    @State private var isTrayClosed: Bool
    
    init(manager: FolloweeManager, client: TidepoolClient) {
        self.manager = manager
        self.client = client
        self._isTrayClosed = State(initialValue: !manager.followees.values.isEmpty)
    }
    
    var body: some View {
        // TODO: list of followed accounts with their summary views
        ZStack {
            ScrollView {
                if manager.followees.isEmpty {
                    welcomeMessage
                } else {
                    followedAccountsList
                }
            }
            if !isTrayClosed {
                Color.black.opacity(0.6)
                    .gesture(TapGesture().onEnded({ isTrayClosed = true }))
            }
            VStack {
                Spacer()
                pendingInviteTray
            }
        }
        .background(background)
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
        .onReceive(timer) { time in
            if scenePhase == .active {
                Task {
                    await manager.refreshFollowees()
                }
            }
        }
    }
    
    private var background: some View {
        LinearGradient(gradient: Gradient(colors: [Color("accent-background"), Color("accent-background").opacity(0.2)]), startPoint: .top, endPoint: .bottom)
    }
    
    private var welcomeMessage: some View {
        VStack(alignment: .leading) {
            Image("following-icon")
                .resizable()
                .frame(width: 77, height: 77)
                .padding(.top, 20)
            Group {
                Text("Welcome to")
                Text("Tidepool Care Partner")
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 1)
            }
            .font(.title)
            .bold()
            Text("Stay in the loop with updates about the high and the lows.")
                .padding(.bottom, 20)
            Text("To follow new accounts, a Tidepool Loop user must invite you to their care team from the Tidepool Loop app.")
                .font(.subheadline)
                .italic()
        }
        .padding(.leading, 20)
        .padding(.trailing, 80)
    }
    
    private var followedAccountsList: some View {
        ForEach(Array(manager.followees.values)) { followee in
            FolloweeStatusView(followee: followee)
        }
    }
    
    private var pendingInviteTray: some View {
        BottomTrayView(isClosed: $isTrayClosed) {
            PendingInviteView(pendingInvites: ["Sally Seastar", "Omar Octopus", "Abigail Albacore", "a"])
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
