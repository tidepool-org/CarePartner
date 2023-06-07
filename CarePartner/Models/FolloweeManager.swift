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

    private let log = OSLog(category: "FolloweeManager")

    var cancellable : AnyCancellable?

    init(client: TidepoolClient) {
        tidepoolClient = client
        followees = [:]

        // When account changes, refresh list
        cancellable = client.$session.dropFirst().sink { [weak self] _ in
            Task {
                await self?.refreshFollowees()
            }
        }

        Task {
            await loadFollowees()
        }
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
            }
        } catch {
            print("Could not get users: \(error)")
        }
    }

    func fetchFolloweeData() async {
        for followee in followees.values {
            Task {
                print("Fetching \(followee.name)")
                await followee.fetchRemoteData(api: tidepoolClient.api)
                print("Fetching complete for \(followee.name)")
            }
        }
    }

    private func followeeFromUser(user: TTrusteeUser) -> Followee? {
        guard let profile = user.profile, let fullName = profile.fullName, user.trustorPermissions?.view != nil else {
            return nil
        }
        let firstName = fullName.components(separatedBy: " ").first ?? fullName
        return Followee(name: firstName, userId: user.userid)
    }

    private func addFollowee(_ followee: Followee) {
        followees[followee.userId] = followee
        followee.delegate = self
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

        let storageURL = followeesPath.appendingPathComponent(followee.userId + ".plist")

        let newValue = followee.rawValue
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: newValue, format: .binary, options: 0)
            try data.write(to: storageURL, options: .atomic)
            os_log(.info, "Wrote %{public}@ to %{public}@", followee.userId, storageURL.absoluteString)
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
