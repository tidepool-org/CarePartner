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

    private let loginSignupViewModel: LoginSignupViewModel

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
        loginSignupViewModel = LoginSignupViewModel(api: viewModel.tidepoolClient.api)
        loginSignupViewModel.loginSignupDelegate = viewModel
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
        .sheet(isPresented: $viewModel.showLogin) {
            LoginSignupView(viewModel: loginSignupViewModel)
                .interactiveDismissDisabled()

        }
        .navigationTitle("Following")
        .toolbar {
            Button(role: .none, action: {
                showingAccountSettings = true
            }) {
                Label("Remove", systemImage: "person.crop.circle")
            }
        }
        .sheet(isPresented: $showingAccountSettings) {
            AccountSettingsView(accountLogin: viewModel.accountLogin) {
                Task {
                    await viewModel.logout()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SummaryView(viewModel: SummaryViewModelMock(
                tidepoolClient: TidepoolClient(),
                accounts: [
                    FollowedAccount.mock
                ]
            ))
        }
        NavigationView {
            SummaryView(viewModel: SummaryViewModelMock(
                tidepoolClient: TidepoolClient(),
                accounts: []
            ))
        }
    }
}
