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

struct PendingInviteView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject private var manager: FolloweeManager
    
    let visibleContentHeight: CGFloat = 20.0
    let discoverableContentHeight: CGFloat = 170.0
    
    let acceptInviteHandler: (PendingInvite) async -> Void
    let rejectInviteHandler: (PendingInvite) async -> Void

    init(manager: FolloweeManager,
        acceptInviteHandler: @escaping (PendingInvite) async -> Void,
         rejectInviteHandler: @escaping (PendingInvite) async -> Void)
    {
        self.manager = manager
        self.acceptInviteHandler = acceptInviteHandler
        self.rejectInviteHandler = rejectInviteHandler
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            
            Group {
                if manager.sortedPendingInvites.isEmpty {
                    noPendingInvitesMessage
                } else {
                    VStack {
                        pendingInviteList
                    }
                }
            }
        }
    }
    
    private var maxHeight: CGFloat {
        discoverableContentHeight + visibleContentHeight
    }
    
    @ViewBuilder
    private var noPendingInvitesMessage: some View {
        Text("You have no pending invites")
            .padding(.vertical, 20)
        
        Button(action: { }) {
            Text("Check for new invites")
        }
        .buttonStyle(ActionButtonStyle())
        .padding(.bottom, 10)
    }
    
    private var pendingInviteList: some View {
        ForEach(manager.sortedPendingInvites, id: \.userDetails.id) { pendingInvite in
            pendingInviteRow(for: pendingInvite)

            if pendingInvite != manager.sortedPendingInvites.last {
                Divider()
            }
        }
    }
    
    private func pendingInviteRow(for pendingInvite: PendingInvite) -> some View {
        VStack(alignment: .leading, spacing: 20) {
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
        .padding(.vertical)
    }
    
    private func rejectButton(for pendingInvite: PendingInvite) -> some View {
        Button(action: {
            Task {
                await rejectInviteHandler(pendingInvite)
            }
        }) {
            Image(systemName: "xmark.circle.fill")
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

struct PendingInviteTitleView: View {
    let pendingInvitationCount: Int
    
    var body: some View {
        HStack {
            Text("Invitations")
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            pendingInvitationCountView
        }
        .padding(.vertical)
    }
    
    private var pendingInvitationCountView: some View {
        HStack {
            Image(systemName: "person.fill")
            Text("\(pendingInvitationCount)")
        }
        .foregroundColor(.accentColor)
    }
}

struct PendingInviteView_Previews: PreviewProvider {
    static var sortedPendingInvites: [PendingInvite] = [
        PendingInvite(userDetails: UserDetails(id: UUID().uuidString, fullName: "Sally Seastar"), key: "sally-key"),
        PendingInvite(userDetails: UserDetails(id: UUID().uuidString, fullName: "Omar Octopus"), key: "omar-key"),
        PendingInvite(userDetails: UserDetails(id: UUID().uuidString, fullName: "Abigail Albacore"), key: "abigail-key")
    ].sorted(by: { $0.userDetails.fullName < $1.userDetails.fullName })
    static var previews: some View {
        PendingInviteView(manager: FolloweeManagerMock(followees: [], pendingInvites: sortedPendingInvites),
                          acceptInviteHandler: { _ in },
                          rejectInviteHandler: { _ in })
        PendingInviteView(manager: FolloweeManagerMock(followees: [], pendingInvites: []),
                          acceptInviteHandler: { _ in },
                          rejectInviteHandler: { _ in })
    }
}
