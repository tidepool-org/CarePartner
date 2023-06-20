//
//  PendingInviteView.swift
//  CarePartner
//
//  Created by Nathaniel Hamming on 2023-06-12.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI
import TidepoolKit

struct PendingInvite: Equatable {
    let userDetails: UserDetails
    let key: String
}

struct PendingInviteView: TrayContent {
    @Environment(\.colorScheme) var colorScheme
    
    var sortedPendingInvites: [PendingInvite]
    
    let visibleContentHeight: CGFloat = 20.0
    let discoverableContentHeight: CGFloat = 170.0
    
    let acceptInviteHandler: (PendingInvite) async -> Void
    let rejectInviteHandler: (PendingInvite) async -> Void

    init(sortedPendingInvites: [PendingInvite],
         acceptInviteHandler: @escaping (PendingInvite) async -> Void,
         rejectInviteHandler: @escaping (PendingInvite) async -> Void)
    {
        self.sortedPendingInvites = sortedPendingInvites
        self.acceptInviteHandler = acceptInviteHandler
        self.rejectInviteHandler = rejectInviteHandler
    }
    
    var body: some View {
        VStack {
            title
            ScrollView {
                if sortedPendingInvites.isEmpty {
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
            Text("\(sortedPendingInvites.count)")
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
        ForEach(sortedPendingInvites, id: \.userDetails.id) { pendingInvite in
            pendingInviteRow(for: pendingInvite)
        }
    }
    
    private func pendingInviteRow(for pendingInvite: PendingInvite) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()
            HStack {
                Text("**\(pendingInvite.userDetails.fullName)** invites you to start following them")
                    .foregroundColor(.primary)
                Spacer()
                Group {
                    rejectButton(for: pendingInvite)
                        .padding(.trailing, 4)
                    acceptButton(for: pendingInvite)
                }
                .font(.system(size: 36))
            }
        }
    }
    
    private func rejectButton(for pendingInvite: PendingInvite) -> some View {
        Button(action: {
            Task {
                await rejectInviteHandler(pendingInvite)
            }
        }) {
            Image(systemName: "x.circle.fill")
                .foregroundStyle(.red, .red.opacity(cancelOpacity))
        }
        .buttonStyle(.plain)
    }
    
    private var cancelOpacity: Double {
        colorScheme == .light ? 0.2 : 0.5
    }
    
    private func acceptButton(for pendingInvite: PendingInvite) -> some View {
        Button(action: {
            Task {
                await acceptInviteHandler(pendingInvite)
            }
        }) {
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
    static var pendingInvites: [PendingInvite] = [
        PendingInvite(userDetails: UserDetails(id: UUID().uuidString, fullName: "Sally Seastar"), key: "sally-key"),
        PendingInvite(userDetails: UserDetails(id: UUID().uuidString, fullName: "Omar Octopus"), key: "omar-key"),
        PendingInvite(userDetails: UserDetails(id: UUID().uuidString, fullName: "Abigail Albacore"), key: "abigail-key")
    ]
    static var previews: some View {
        PendingInviteView(pendingInvites: pendingInvites,
                          acceptInviteHandler: { _ in },
                          rejectInviteHandler: { _ in })
        PendingInviteView(pendingInvites: [],
                          acceptInviteHandler: { _ in },
                          rejectInviteHandler: { _ in })
    }
}
