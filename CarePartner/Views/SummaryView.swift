//
//  ContentView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//

import SwiftUI
import TidepoolKit

struct SummaryView: View {

    @ObservedObject private var viewModel: SummaryViewModel

    @State private var showingAccountSettings = false

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        // TODO: list of followed accounts with their summary views
        ScrollView {
            if viewModel.accounts.isEmpty {
                Text("No accounts have shared data with you yet.")
                    .padding(.horizontal)
            } else {
                ForEach(viewModel.accounts, id: \.name) { account in
                    FolloweeSummaryView(account: account)
                }
            }
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView(client: viewModel.tidepoolClient)
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
            if viewModel.tidepoolClient.hasSession {
                await viewModel.refreshFollowees()
            } else {
                self.showingAccountSettings = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SummaryView(viewModel: SummaryViewModelMock(
                accounts: [
                    FollowedAccount.mock
                ]
            ))
        }
        NavigationView {
            SummaryView(viewModel: SummaryViewModelMock(
                accounts: []
            ))
        }
    }
}
