//
//  SummaryViewModel.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import Combine
import os.log

@MainActor
class FolloweeManager: ObservableObject {

    private let tidepoolClient: TidepoolClient

    @Published var followees: [String: Followee]
    
    @Published var pendingInvites: [String: PendingInvite]

    private let log = OSLog(category: "FolloweeManager")

    var cancellable : AnyCancellable?
    
    var sortedPendingInvites: [PendingInvite] {
        pendingInvites.values.map { $0 }.sorted(by: { $0.userDetails.fullName < $1.userDetails.fullName })
    }
    
    init(client: TidepoolClient) {
        tidepoolClient = client
        followees = [:]
        pendingInvites = [:]

        // When account changes, refresh list
        cancellable = client.$session.dropFirst().sink { [weak self] _ in
            Task {
                await self?.refreshAll()
            }
        }

        Task {
            await loadFollowees()
        }
    }
    
    public func refreshAll() async {
        await refreshFollowees()
        await refreshPendingInvites()
    }

    public func refreshFollowees() async {
        do {
            if tidepoolClient.hasSession {
                let users = try await tidepoolClient.api.getUsers()
                let followedUserIds = users.map { $0.userid }

                // Remove unfollowed accounts
                for followee in followees.keys {
                    if !followedUserIds.contains(followee) {
                        followees[followee] = nil
                    }
                }

                // Add newly followed accounts
                for user in users {
                    if !followees.keys.contains(user.userid), let followee = followeeFromUser(user: user) {
                        storeFollowee(followee)
                        addFollowee(followee)
                    }
                }
                
                // Refresh all accounts
                await fetchFolloweeData()
            } else {
                followees = [:]
            }
        } catch {
            log.error("Could not get users: : %{public}@", error.localizedDescription)
        }
    }
    
    func refreshPendingInvites() async {
        do {
            if tidepoolClient.hasSession {
                let pendingInvitesReceived = try await tidepoolClient.api.getPendingInvitesReceived()
                let receivedPendingInvites = pendingInvitesReceived.map { PendingInvite(userDetails: UserDetails(id: $0.creatorId, fullName: $0.creator.profile.fullName ?? "Unknown"), key: $0.key) }
                
                for pendingInvite in pendingInvites.values {
                    if !receivedPendingInvites.contains(pendingInvite) {
                        pendingInvites[pendingInvite.userDetails.id] = nil
                    }
                }
                
                for pendingInvite in receivedPendingInvites {
                    if !pendingInvites.keys.contains(pendingInvite.userDetails.id) {
                        pendingInvites[pendingInvite.userDetails.id] = pendingInvite
                    }
                }
            } else {
                pendingInvites = [:]
            }
        } catch {
            log.error("Could not get pending invites: %{public}@", error.localizedDescription)
        }
    }

    func fetchFolloweeData() async {
        for followee in followees.values {
            Task {
                print("Fetching \(followee.userDetails.fullName)")
                await followee.fetchRemoteData(api: tidepoolClient.api)
                print("Fetching complete for \(followee.userDetails.fullName)")
            }
        }
    }

    private func followeeFromUser(user: TTrusteeUser) -> Followee? {
        guard let profile = user.profile, let fullName = profile.fullName, user.trustorPermissions?.view != nil else {
            return nil
        }
        return Followee(fullName: fullName, userId: user.userid)
    }

    private func addFollowee(_ followee: Followee) {
        followees[followee.userDetails.id] = followee
        followee.delegate = self
    }
    
    func acceptInvite(pendingInvite: PendingInvite) async -> Bool {
        do {
            try await tidepoolClient.api.acceptInvite(invitedByUserId: pendingInvite.userDetails.id, key: pendingInvite.key)
            return true
        } catch {
            log.error("Could not accept invite from %{public}@: %{public}@", pendingInvite.userDetails.fullName, error.localizedDescription)
            return false
        }
    }
    
    func rejectInvite(pendingInvite: PendingInvite) async -> Bool {
        do {
            try await tidepoolClient.api.rejectInvite(invitedByUserId: pendingInvite.userDetails.id, key: pendingInvite.key)
            return true
        } catch {
            log.error("Could not reject invite from %{public}@: %{public}@", pendingInvite.userDetails.fullName, error.localizedDescription)
            return false
        }
    }

    // MARK: Persistence
    private func loadFollowees() async {

        let loadFolloweesTask: Task<[Followee], Never> = Task.detached(priority: .userInitiated) {

            let fm = FileManager.default

            guard let localDocuments = try? fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
                preconditionFailure("Could not get a documents directory URL.")
            }
            let followeesPath = localDocuments.appendingPathComponent("followees")
            if !fm.fileExists(atPath: followeesPath.path) {
                // No followees stored
                return []
            }

            var followees: [Followee] = []

            do {
                let files = try fm.contentsOfDirectory(at: followeesPath, includingPropertiesForKeys: nil)
                for file in files {
                    print("Found \(file)")
                    let userId = file.deletingPathExtension().lastPathComponent

                    print("last \(file.deletingPathExtension().lastPathComponent)")

                    let data = try Data(contentsOf: file)
                    self.log.info("Reading %{public}@ from %{public}@", userId, file.absoluteString)
                    guard let value = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? Followee.RawValue else {
                        self.log.error("Unexpected type for %{public}@", userId)
                        continue
                    }
                    if let followee = await Followee(rawValue: value) {
                        followees.append(followee)
                    }
                }
            } catch {
                self.log.error("Could not list contents of directory %{public}@: %{public}@", followeesPath.absoluteString, error.localizedDescription)
            }

            return followees
        }
        let storedFollowees = await loadFolloweesTask.value

        for followee in storedFollowees {
            addFollowee(followee)
        }
    }

    private func storeFollowee(_ followee: Followee) {
        let fm = FileManager.default
        guard let localDocuments = try? fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            preconditionFailure("Could not get a documents directory URL.")
        }
        let followeesPath = localDocuments.appendingPathComponent("followees")
        if !fm.fileExists(atPath: followeesPath.path) {
            do {
                try fm.createDirectory(atPath: followeesPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                preconditionFailure("Could not create storage directory: \(error.localizedDescription)")
            }
        }

        let storageURL = followeesPath.appendingPathComponent(followee.userDetails.id + ".plist")

        let newValue = followee.rawValue
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: newValue, format: .binary, options: 0)
            try data.write(to: storageURL, options: .atomic)
            os_log(.info, "Wrote %{public}@ to %{public}@", followee.userDetails.id, storageURL.absoluteString)
        } catch {
            os_log(.error, "Error saving %{public}@: %{public}@", storageURL.absoluteString, error.localizedDescription)
        }
    }
}

extension FolloweeManager: FolloweeDelegate {
    func stateDidChange(for followee: Followee) {
        storeFollowee(followee)
    }
}
