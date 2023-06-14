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
    
    var pendingInvites: [String]
    
    let visibleContentHeight: CGFloat = 20.0
    let discoverableContentHeight: CGFloat = 170.0
    
    var body: some View {
        VStack {
            title
            ScrollView {
                if pendingInvites.isEmpty {
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
            Text("\(pendingInvites.count)")
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
        ForEach(pendingInvites, id: \.self) { pendingInvite in
            pendingInviteRow(for: pendingInvite)
        }
    }
    
    private func pendingInviteRow(for pendingInvite: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()
            HStack {
                Text("**\(pendingInvite)** invites you to start following them")
                    .foregroundColor(.primary)
                Spacer()
                Group {
                    cancelButton(for: pendingInvite)
                        .padding(.trailing, 4)
                    acceptButton(for: pendingInvite)
                }
                .font(.system(size: 36))
            }
        }
    }
    
    private func cancelButton(for pendingInvite: String) -> some View {
        Button(action: { print("deny \(pendingInvite)!") }) {
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.red, .red.opacity(cancelOpacity))
        }
        .buttonStyle(.plain)
    }
    
    private var cancelOpacity: Double {
        colorScheme == .light ? 0.2 : 0.5
    }
    
    private func acceptButton(for pendingInvite: String) -> some View {
        Button(action: { print("accept \(pendingInvite)!") }) {
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
    static var previews: some View {
        PendingInviteView(pendingInvites: ["Sally Seastar", "Omar Octopus", "Abigail Albacore"])
        PendingInviteView(pendingInvites: [])
    }
}
