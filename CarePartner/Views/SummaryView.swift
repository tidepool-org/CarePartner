//
//  ContentView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//

import SwiftUI
import TidepoolKit
import TidepoolKitUI

struct SummaryView: View {

    @ObservedObject private var viewModel: SummaryViewModel

    private let loginSignupViewModel: LoginSignupViewModel

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
        loginSignupViewModel = LoginSignupViewModel(api: viewModel.tidepoolClient.api)
        loginSignupViewModel.loginSignupDelegate = viewModel
    }

    var body: some View {
        // TODO: list of followed accounts with their summary views
        List {
            if viewModel.accounts.isEmpty {
                Text("No accounts have shared data with you yet.")
            } else {
                ForEach(viewModel.accounts, id: \.name) { account in
                    Text(account.name)
                }
            }
        }
        .sheet(isPresented: $viewModel.showLogin) {
            LoginSignupView(viewModel: loginSignupViewModel)
        }
        .navigationTitle("Following")
        .toolbar {
            Button(role: .none, action: {
                print("Account tapped!")
            }) {
                Label("Remove", systemImage: "person.crop.circle")
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
                    FollowedAccount(name: "Sally")
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
