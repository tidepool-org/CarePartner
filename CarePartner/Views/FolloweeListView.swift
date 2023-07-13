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
    @State private var selectedDetent = TrayState.closed.presentationDetent
    @State private var showingPendingInvites = false
    @State private var isPendingInviteDisabled = false
    
    private enum TrayState {
        case openedFull
        case openedPartial
        case closed
                
        var presentationDetent: PresentationDetent {
            switch self {
            case .openedFull: return .fraction(0.3)
            case .openedPartial: return .fraction(0.185)
            case .closed: return .fraction(0.06)
            }
        }
        
        var isOpen: Bool {
            self == .openedFull || self == .openedPartial
        }
        
        static func trayState(for selectedDetent: PresentationDetent) -> TrayState {
            selectedDetent == TrayState.openedFull.presentationDetent ? .openedFull : selectedDetent == TrayState.openedPartial.presentationDetent ? .openedPartial : .closed
        }
        
        static func trayTopPadding(for selectedDetent: PresentationDetent) -> CGFloat {
            let trayState = trayState(for: selectedDetent)
            return trayState == .closed ? 30 : trayState == .openedPartial ? 18 : 0
        }
        
        static func trayPresentationDetents(canTrayOpenFully: Bool) -> Set<PresentationDetent> {
            canTrayOpenFully ? [self.openedFull.presentationDetent, self.closed.presentationDetent] : [self.openedPartial.presentationDetent, self.closed.presentationDetent]
        }
        
        static func determineTrayOpenness(canTrayOpenFully: Bool) -> PresentationDetent {
            canTrayOpenFully ? self.openedFull.presentationDetent : self.openedPartial.presentationDetent
        }
    }

    private var canTrayOpenFully: Bool {
        // when there is only 1 pending invite, only open the tray partially
        manager.sortedPendingInvites.count != 1
    }
        
    private var trayState: TrayState { TrayState.trayState(for: selectedDetent) }
    private var trayPresentationDetents: Set<PresentationDetent> { TrayState.trayPresentationDetents(canTrayOpenFully: canTrayOpenFully) }
    private var trayTopPadding: CGFloat { TrayState.trayTopPadding(for: selectedDetent) }
        
    init(manager: FolloweeManager, client: TidepoolClient) {
        self.manager = manager
        self.client = client
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
            if trayState.isOpen {
                // dim out background views, but add tap to close tray
                Color.black.opacity(0.6)
                    .gesture(tapToCloseTray)
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
            await refreshLists()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await refreshLists()
                }
            }
        }
        .onReceive(timer) { time in
            if scenePhase == .active {
                Task {
                    await refreshLists()
                }
            }
        }
    }
    
    private var tapToCloseTray: some Gesture {
        TapGesture().onEnded({ selectedDetent = TrayState.closed.presentationDetent })
    }
        
    private func refreshLists() async {
        print("Do your refresh work here")
        await manager.refreshAll()
        
        displayPendingInvitesIfNeeded()
    }
    
    private func displayPendingInvitesIfNeeded() {
        if !showingPendingInvites && manager.followees.values.isEmpty {
            // open the pending invite tray
            showingPendingInvites = true
            selectedDetent = TrayState.determineTrayOpenness(canTrayOpenFully: canTrayOpenFully)
        } else if !showingPendingInvites && !manager.pendingInvites.values.isEmpty {
            // just display the tray but not open
            showingPendingInvites = true
            selectedDetent = TrayState.closed.presentationDetent
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
            FolloweeStatusView(
                followee: followee,
                initiallyExpanded: manager.followees.count == 1
            )
        }
    }
    
    private var pendingInviteTray: some View {
        ZStack {
            Group {
                if trayState == .closed {
                    // display just the title
                    PendingInviteTitleView(pendingInvitationCount: manager.sortedPendingInvites.count)
                } else {
                    PendingInviteView(sortedPendingInvites: manager.sortedPendingInvites,
                                      acceptInviteHandler: { pendingInvite in await acceptInvite(pendingInvite) },
                                      rejectInviteHandler: { pendingInvite in await rejectInvite(pendingInvite) })
                    if isPendingInviteDisabled {
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, trayTopPadding)
            .interactiveDismissDisabled()
            .presentationDetents(trayPresentationDetents, selection: $selectedDetent)
            .presentationBackgroundInteraction(.enabled(upThrough: trayState.presentationDetent))
        }
        .contentShape(Rectangle())
        .gesture(trayTapGesture)
    }
    
    private func acceptInvite(_ pendingInvite: PendingInvite) async {
        isPendingInviteDisabled = true
        let success = await manager.acceptInvite(pendingInvite: pendingInvite)
        if success {
            await refreshLists()
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
            if trayState != .closed { selectedDetent = TrayState.closed.presentationDetent }
            else { selectedDetent = TrayState.determineTrayOpenness(canTrayOpenFully: canTrayOpenFully) }
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
