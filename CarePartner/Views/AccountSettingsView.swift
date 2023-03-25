//
//  AccountSettingsView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 3/25/23.
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var accountLogin: String
    var didRequestDelete: () -> Void

    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Tidepool ")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Image(decorative: "Tidepool Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)


                VStack(spacing: 0) {
                    HStack {
                        Text("Account")
                        Spacer()
                        Text(accountLogin)
                    }
                    .padding()
                }

                Button(action: {
                    showingAlert = true
                } ) {
                    Text("Logout").padding(.top, 20)
                }
                Spacer()
            }
            .padding([.leading, .trailing])
            .navigationBarTitle("")
            .navigationBarItems(trailing: dismissButton)
            .alert(Text("Are you sure you want to log out of this account?", comment: "Confirmation message for logging out of the account"), isPresented: $showingAlert)
            {
                Button("Logout", role: .destructive) {
                    didRequestDelete()
                    dismiss()
                }
            }
        }
    }

    private var dismissButton: some View {
        Button(action: { dismiss() } ) {
            Text("Done").bold()
        }
    }}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(accountLogin: "test@test.com") {
            print("Delete Service!")
        }
    }
}
