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

enum TrayState {
    case opened
    case closed
    
    static var presentationDetents: Set<PresentationDetent> {
        [Self.opened.presentationDetent, Self.closed.presentationDetent]
    }
    
    var presentationDetent: PresentationDetent {
        switch self {
        case .opened: return .fraction(0.3)
        case .closed: return .fraction(0.05)
        }
    }
}

struct FolloweeListView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject private var manager: FolloweeManager
    @ObservedObject private var client: TidepoolClient
    
    let timer = Timer.publish(every: .minutes(1), on: .main, in: .common).autoconnect()
    
    @State private var showingAccountSettings = false
    @State private var selectedDetent = TrayState.closed.presentationDetent
    @State private var showingPendingInvites = false
    @State private var isPendingInviteDisabled = false
    
    init(manager: FolloweeManager, client: TidepoolClient) {
        self.manager = manager
        self.client = client
        self.showingPendingInvites = !manager.pendingInvites.isEmpty
    }
    
    private var trayTopPadding: CGFloat { trayState == .closed ? 20 : 0 }
    
    private var trayState: TrayState { selectedDetent == TrayState.opened.presentationDetent ? .opened : .closed }
    
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
            if trayState == .opened {
                Color.black.opacity(0.6)
                    .gesture(TapGesture().onEnded({ selectedDetent = TrayState.closed.presentationDetent }))
            }
        }
        .background(background)
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView(client: client)
        }
        .sheet(isPresented: $showingPendingInvites) {
            pendingInviteTray
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
            await refresh()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await refresh()
                }
            }
        }
        .onReceive(timer) { time in
            if scenePhase == .active {
                Task {
                    await refresh()
                }
            }
        }
    }
        
    private func refresh() async {
        print("Do your refresh work here")
        await manager.refreshFollowees()
        await manager.refreshPendingInvites()
        if !showingPendingInvites && manager.followees.values.isEmpty ||
            !showingPendingInvites && !manager.pendingInvites.values.isEmpty
        {
            showingPendingInvites = true
            selectedDetent = TrayState.opened.presentationDetent
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
        ZStack {
            PendingInviteView(sortedPendingInvites: manager.sortedPendingInvites,
                              acceptInviteHandler: { pendingInvite in await acceptInvite(pendingInvite) },
                              rejectInviteHandler: { pendingInvite in await rejectInvite(pendingInvite) })
            .padding(.horizontal)
            .padding(.top, trayTopPadding)
            .interactiveDismissDisabled()
            .presentationDetents(TrayState.presentationDetents, selection: $selectedDetent)
            .presentationBackgroundInteraction(.enabled(upThrough: TrayState.opened.presentationDetent))

            if isPendingInviteDisabled {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }
        }
        .contentShape(Rectangle())
        .gesture(trayTapGesture)
    }
    
    private func acceptInvite(_ pendingInvite: PendingInvite) async {
        isPendingInviteDisabled = true
        let success = await manager.acceptInvite(pendingInvite: pendingInvite)
        if success {
            await refresh()
        }
        isPendingInviteDisabled = false
    }
    
    private func rejectInvite(_ pendingInvite: PendingInvite) async {
        isPendingInviteDisabled = true
        let success = await manager.rejectInvite(pendingInvite: pendingInvite)
        if success {
            await manager.refreshPendingInvites()
        }
        isPendingInviteDisabled = false
    }
    
    private var trayTapGesture: some Gesture {
        TapGesture().onEnded({
            if trayState == .opened { selectedDetent = TrayState.closed.presentationDetent }
            else { selectedDetent = TrayState.opened.presentationDetent }
        })
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
                    ],
                    pendingInvites: [PendingInvite(userDetails: UserDetails.mockOmar, key: "omar-key"), PendingInvite(userDetails: UserDetails.mockAbigail, key: "abigail-key")]),
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
