//
//  PendingInviteView.swift
//  CarePartner
//
//  Created by Nathaniel Hamming on 2023-06-12.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI
import TidepoolKit

struct PendingInviteView: TrayContent {
    @Environment(\.colorScheme) var colorScheme
    
    var pendingInviteUserDetails: [UserDetails]
    
    let visibleContentHeight: CGFloat = 20.0
    let discoverableContentHeight: CGFloat = 170.0
    
    var body: some View {
        VStack {
            title
            ScrollView {
                if pendingInviteUserDetails.isEmpty {
                    noPendingInvitesMessage
                } else {
                    pendingInviteList
                }
            }
        }
        .frame(maxHeight: maxHeight)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var maxHeight: CGFloat {
        discoverableContentHeight + visibleContentHeight
    }
    
    private var title: some View {
        HStack {
            Text("Invitations")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            pendingInvitationCount
        }
        .padding(.top, 6)
        .padding(.bottom, 12)
    }
    
    private var pendingInvitationCount: some View {
        HStack {
            Image(systemName: "person.fill")
            Text("\(pendingInviteUserDetails.count)")
        }
        .foregroundColor(.accentColor)
    }
    
    private var noPendingInvitesMessage: some View {
        VStack {
            Divider()
            Text("You have no pending invites")
                .padding(.vertical, 20)
            Button(action: { }) {
                Text("Check for new invites")
            }
                .buttonStyle(ActionButtonStyle())
                .padding(.bottom, 10)
        }
    }
    
    private var pendingInviteList: some View {
        ForEach(pendingInviteUserDetails, id: \.id) { userDetails in
            pendingInviteRow(for: userDetails)
        }
    }
    
    private func pendingInviteRow(for userDetails: UserDetails) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()
            HStack {
                Text("**\(userDetails.fullName)** invites you to start following them")
                    .foregroundColor(.primary)
                Spacer()
                Group {
                    cancelButton(for: userDetails)
                        .padding(.trailing, 4)
                    acceptButton(for: userDetails)
                }
                .font(.system(size: 36))
            }
        }
    }
    
    private func cancelButton(for userDetails: UserDetails) -> some View {
        // TODO placeholder
        Button(action: { print("deny \(userDetails.fullName)!") }) {
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.red, .red.opacity(cancelOpacity))
        }
        .buttonStyle(.plain)
    }
    
    private var cancelOpacity: Double {
        colorScheme == .light ? 0.2 : 0.5
    }
    
    private func acceptButton(for userDetails: UserDetails) -> some View {
        // TODO placeholder
        Button(action: { print("accept \(userDetails.fullName)!") }) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.accentColor, Color.accentColor.opacity(acceptOpacity))
        }
        .buttonStyle(.plain)
    }
    
    private var acceptOpacity: Double {
        colorScheme == .light ? 0.25 : 0.5
    }
}

struct PendingInviteView_Previews: PreviewProvider {
    static var pendingInviteUserDetails: [UserDetails] = [
        UserDetails(id: UUID().uuidString, fullName: "Sally Seastar"),
        UserDetails(id: UUID().uuidString, fullName: "Omar Octopus"),
        UserDetails(id: UUID().uuidString, fullName: "Abigail Albacore"),
    ]
    static var previews: some View {
        PendingInviteView(pendingInviteUserDetails: pendingInviteUserDetails)
        PendingInviteView(pendingInviteUserDetails: [])
    }
}
