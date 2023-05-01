//
//  AccountSettingsView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 3/25/23.
//

import SwiftUI
import TidepoolKit

public struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss


    @State private var isEnvironmentActionSheetPresented = false
    @State private var showingDeletionConfirmation = false

    @State private var error: Error?
    @State private var isLoggingIn = false
    @State private var selectedEnvironment: TEnvironment
    @State private var environments: [TEnvironment] = [TEnvironment.productionEnvironment]
    @State private var environmentFetchError: Error?

    @ObservedObject private var client: TidepoolClient

    init(client: TidepoolClient)
    {
        self.client = client
        let defaultEnvironment = client.api.defaultEnvironment
        self._selectedEnvironment = State(initialValue: client.session?.environment ?? defaultEnvironment ?? TEnvironment.productionEnvironment)
    }

    public var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        HStack() {
                            Spacer()
                            closeButton
                                .padding()
                        }
                        Spacer()
                        logo
                            .padding(.horizontal, 30)
                            .padding(.bottom)
                        if selectedEnvironment != TEnvironment.productionEnvironment {
                            VStack {
                                Text(NSLocalizedString("Environment", comment: "Label title for displaying selected Tidepool server environment."))
                                    .bold()
                                Text(selectedEnvironment.description)
                            }
                        }
                        if let username = client.session?.username {
                            VStack {
                                Text(NSLocalizedString("Logged in as", comment: "LoginViewModel description text when logged in"))
                                    .bold()
                                Text(username)
                            }
                        } else {
                            Text(NSLocalizedString("You are not logged in.", comment: "LoginViewModel description text when not logged in"))
                                .padding()
                        }

                        if let error {
                            VStack(alignment: .leading) {
                                Text(error.localizedDescription)
                                    .font(.callout)
                                    .foregroundColor(.red)
                            }
                            .padding()
                        }
                        Spacer()
                        if client.hasSession {
                            deleteServiceButton
                        } else {
                            loginButton
                        }
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .alert(NSLocalizedString("Are you sure you want to logout?", comment: "Confirmation message for logging out"), isPresented: $showingDeletionConfirmation)
        {
            Button(NSLocalizedString("Logout", comment: "Button title to logout"), role: .destructive) {
                Task {
                    await client.logout()
                }
            }
        }
        .task {
            do {
                environments = try await TEnvironment.fetchEnvironments()
            } catch {

            }
        }

    }

    private var logo: some View {
        VStack {
            Text("Tidepool ")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image(decorative: "Tidepool Logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .onLongPressGesture(minimumDuration: 2) {
                    if !client.hasSession {
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        isEnvironmentActionSheetPresented = true
                    }
                }
                .actionSheet(isPresented: $isEnvironmentActionSheetPresented) { environmentActionSheet }
        }
    }

    private var environmentActionSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = environments.map { environment in
            .default(Text(environment.description)) {
                error = nil
                selectedEnvironment = environment
            }
        }
        buttons.append(.cancel())


        return ActionSheet(title: Text(NSLocalizedString("Environment", comment: "Tidepool login environment action sheet title")),
                           message: Text(selectedEnvironment.description), buttons: buttons)
    }

    private var loginButton: some View {
        Button(action: {
            loginButtonTapped()
        }) {
            if isLoggingIn {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text(NSLocalizedString("Login", comment: "Tidepool login button title"))
            }
        }
        .buttonStyle(ActionButtonStyle())
        .disabled(isLoggingIn)
    }


    private var deleteServiceButton: some View {
        Button(action: {
            showingDeletionConfirmation = true
        }) {
            Text(NSLocalizedString("Delete Service", comment: "Delete Tidepool service button title"))
        }
        .buttonStyle(ActionButtonStyle(.secondary))
        .disabled(isLoggingIn)
    }

    private func loginButtonTapped() {
        guard !isLoggingIn else {
            return
        }

        error = nil
        isLoggingIn = true

        Task {
            do {
                try await login()
                isLoggingIn = false
            } catch {
                self.error = error
                isLoggingIn = false
            }
        }
    }

    private func login() async throws {
        // use selectedEnvironment

    }

    private var closeButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text(closeButtonTitle)
                .fontWeight(.regular)
        }
    }

    private var closeButtonTitle: String { NSLocalizedString("Close", comment: "Close navigation button title of an onboarding section page view") }
}

struct SettingsView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        AccountSettingsView(client: TidepoolClient())
    }
}

