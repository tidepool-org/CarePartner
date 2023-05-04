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
    @EnvironmentObject var sceneDelegate: SceneDelegate

    @State private var isEnvironmentActionSheetPresented = false
    @State private var showingLogoutConfirmation = false

    @State private var error: Error?
    @State private var isLoggingIn = false
    @State private var selectedEnvironment: TEnvironment
    @State private var environments: [TEnvironment] = [TEnvironment.productionEnvironment]
    @State private var profile: TProfile?

    @ObservedObject private var client: TidepoolClient

    init(client: TidepoolClient)
    {
        self.client = client
        let defaultEnvironment = client.api.defaultEnvironment
        self._selectedEnvironment = State(initialValue: client.session?.environment ?? defaultEnvironment ?? TEnvironment.productionEnvironment)
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                logo
                    .padding(.bottom)
                VStack(alignment: .leading, spacing: 0) {
                    if let profile, let fullName = profile.fullName {
                        HStack {
                            Text(fullName)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "person.crop.circle")
                                .font(Font.system(.largeTitle))
                                .fontWeight(.thin)
                                .foregroundColor(.accentColor)
                        }
                    }
                    if let session = client.session {
                        Text(session.username)
                    }
                }
                if !client.hasSession {
                    Text(NSLocalizedString("You are not logged in.", comment: "LoginViewModel description text when not logged in"))
                        .padding()
                }

                Spacer()
                if selectedEnvironment != TEnvironment.productionEnvironment {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("Environment", comment: "Label title for displaying selected Tidepool server environment."))
                            .bold()
                        Text(selectedEnvironment.description)
                    }
                }

                if let error {
                    VStack(alignment: .leading) {
                        Text(error.localizedDescription)
                            .font(.callout)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                if client.hasSession {
                    logoutButton
                } else {
                    loginButton
                }
            }
            .padding()
            .navigationTitle(NSLocalizedString("My Account", comment: "title for AccountSettingsView"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                closeButton
            }
        }
        .alert(NSLocalizedString("Are you sure you want to logout?", comment: "Confirmation message for logging out"), isPresented: $showingLogoutConfirmation)
        {
            Button(NSLocalizedString("Logout", comment: "Button title to logout"), role: .destructive) {
                Task {
                    await client.logout()
                }
            }
        }
        .task {
            environments = (try? await TEnvironment.fetchEnvironments()) ?? []
            await refreshProfile()
        }
        .onChange(of: client.session) { newValue in
            Task {
                await refreshProfile()
            }
        }
    }

    private func refreshProfile() async {
        if client.hasSession {
            do {
                profile = try await client.api.getProfile()
            } catch {
                self.error = error
            }
        } else {
            profile = nil
        }
    }

    private var logo: some View {
        VStack {
            Image(decorative: "Tidepool Logo Full")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaledToFit()
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


    private var logoutButton: some View {
        Button(action: {
            showingLogoutConfirmation = true
        }) {
            Text(NSLocalizedString("Logout", comment: "Logout button title"))
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
                try await client.login(environment: selectedEnvironment, sceneDelegate: sceneDelegate)
                isLoggingIn = false
            } catch {
                self.error = error
                isLoggingIn = false
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text(NSLocalizedString("Done", comment: "Done navigation button title on AccountSettingsView"))
                .fontWeight(.regular)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(client: TidepoolClient.loggedInMock)
    }
}

