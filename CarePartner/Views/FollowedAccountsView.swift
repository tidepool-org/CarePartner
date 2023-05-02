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
        ScrollView {
            if followedAccounts.accounts.isEmpty {
                Text("No accounts have shared data with you yet.")
                    .padding(.horizontal)
            } else {
                ForEach(followedAccounts.accounts, id: \.name) { account in
                    AccountView(accountData: account)
                }
            }
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView(client: client)
        }
        .navigationTitle("Following")
        .toolbar {
            Button(role: .none, action: {
                showingAccountSettings = true
            }) {
                Label("Remove", systemImage: "person.crop.circle")
            }
        }
        .task {
            if client.hasSession {
                await followedAccounts.refreshFollowees()
            } else {
                self.showingAccountSettings = true
            }
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
            ), client: TidepoolClient())
        }
        NavigationView {
            FollowedAccountsView(followedAccounts: FollowedAccountsMock(
                accounts: []
            ), client: TidepoolClient())
        }
    }
}
