//
//  FollowedAccountsView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//

import SwiftUI
import TidepoolKit

struct FollowedAccountsView: View {

    @ObservedObject private var followedAccounts: FollowedAccounts
    @ObservedObject private var client: TidepoolClient

    @State private var showingAccountSettings = false

    init(followedAccounts: FollowedAccounts, client: TidepoolClient) {
        self.followedAccounts = followedAccounts
        self.client = client
    }

    var body: some View {
        // TODO: list of followed accounts with their summary views
        VStack {
            ScrollView {
                if followedAccounts.accounts.isEmpty {
                    welcomeMessage
                } else {
                    followedAccountsList
                }
            }
            Spacer()
            pendingInviteTray
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
        ForEach(followedAccounts.accounts, id: \.userid) { account in
            AccountView(accountData: account)
        }
    }
    
    private var pendingInviteTray: some View {
        BottomTrayView() {
            PendingInviteView(pendingInvites: ["Sally Seastar", "Omar Octopus", "Abigail Albacore"])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FollowedAccountsView(followedAccounts: FollowedAccountsMock(
                accounts: [
                    AccountData.mock
                ]
            ), client: TidepoolClient.loggedInMock)
        }
        NavigationView {
            FollowedAccountsView(followedAccounts: FollowedAccountsMock(
                accounts: []
            ), client: TidepoolClient.loggedInMock)
        }
    }
}
