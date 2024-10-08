//
//  FolloweeStatus.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/28/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import LoopAlgorithm
import HealthKit
import LoopKit
import CoreData
import TidepoolKit
import os.log
import Combine

protocol FolloweeDelegate: AnyObject {
    func stateDidChange(for followee: Followee)
}

struct UserDetails: Equatable {
    var id: String
    var fullName: String
    
    var firstName: String {
        fullName.components(separatedBy: " ").first ?? fullName
    }
}

extension UserDetails {
    static var mockOmar: UserDetails {
        return UserDetails(id: UUID().uuidString, fullName: "Omar Octopus")
    }
    
    static var mockAbigail: UserDetails {
        return UserDetails(id: UUID().uuidString, fullName: "Abigail Albacore")
    }
}

@MainActor
class Followee: ObservableObject, Identifiable {
    typealias RawValue = [String: Any]

    @Published var status: FolloweeStatus
    @Published var isLoading: Bool = false

    let userDetails: UserDetails

    let glucoseStore: GlucoseStore
    let doseStore: DoseStore
    let carbStore: CarbStore
    let dosingDecisionStore: DosingDecisionStore

    private let log = OSLog(category: "Followee")
    var cancellables: Set<AnyCancellable> = []

    weak var delegate: FolloweeDelegate?

    init(fullName: String, userId: String, lastRefresh: Date = .distantPast) {
        self.userDetails = UserDetails(id: userId, fullName: fullName)

        let url = NSPersistentContainer.defaultDirectoryURL.appendingPathComponent(userId)
        let cacheStore = PersistenceController(directoryURL: url)
        let provenanceIdentifier = HKSource.default().bundleIdentifier

        let historyInterval = TimeInterval(days: 7)

        glucoseStore = GlucoseStore(
            cacheStore: cacheStore,
            cacheLength: historyInterval,
            provenanceIdentifier: provenanceIdentifier
        )

        doseStore = DoseStore(
            cacheStore: cacheStore,
            cacheLength: historyInterval,
            basalProfile: nil,
            insulinSensitivitySchedule: nil,
            provenanceIdentifier: provenanceIdentifier)

        carbStore = CarbStore(
            cacheStore: cacheStore,
            cacheLength: historyInterval,
            provenanceIdentifier: provenanceIdentifier)

        dosingDecisionStore = DosingDecisionStore(
            store: cacheStore,
            expireAfter: historyInterval)

        status = FolloweeStatus(firstName: userDetails.firstName, lastRefresh: lastRefresh)

        NotificationCenter.default.publisher(for: GlucoseStore.glucoseSamplesDidChange, object: nil)
            .receive(on: RunLoop.main)
            .sink() { [weak self] _ in
                Task {
                    await self?.refreshGlucose()
                }
            }
            .store(in: &cancellables)

        glucoseStore.onReady { error in
            if error == nil {
                Task {
                    await self.refreshGlucose()
                }
            }
        }
        Task {
            await self.getLatestDosingDecision()
            await self.refreshInsulinData()
            await self.refreshMealData()
        }
    }

    convenience init?(rawValue: [String : Any]) {
        guard let fullName = rawValue["fullName"] as? String,
              let userId = rawValue["userId"] as? String
        else { return nil }

        let lastRefresh = rawValue["lastRefresh"] as? Date ?? .distantPast

        self.init(fullName: fullName, userId: userId, lastRefresh: lastRefresh)
    }

    var rawValue: [String : Any] {
        return [
            "fullName": userDetails.fullName,
            "userId": userDetails.id,
            "lastRefresh": status.lastRefresh
        ]
    }

    func getLatestDosingDecision() async {
        do {
            if let latest = try await dosingDecisionStore.fetchLatestDosingDecision() {
                if let cob = latest.carbsOnBoard {
                    status.activeCarbs = cob
                }
                if let iob = latest.insulinOnBoard {
                    status.activeInsulin = iob
                }
            }

        } catch {
            log.error("Unable to fetch dosing decisions: %{public}@", error.localizedDescription)
        }
    }

    func refreshGlucose() async {
        if let latest = glucoseStore.latestGlucose as? StoredGlucoseSample, latest.startDate.timeIntervalSinceNow > -.minutes(15) {
            status.latestGlucose = latest
            do {
                let samples = try await glucoseStore.getGlucoseSamples(start: latest.startDate.addingTimeInterval(-.minutes(6)))
                if let previousSample = samples.filter({ $0.syncIdentifier != latest.syncIdentifier }).sorted(by: \.startDate).last {
                    let delta = latest.quantity.doubleValue(for: .milligramsPerDeciliter) - previousSample.quantity.doubleValue(for: .milligramsPerDeciliter)
                    status.glucoseDelta = HKQuantity(unit: .milligramsPerDeciliter, doubleValue: delta)
                } else {
                    status.glucoseDelta = nil
                }
            } catch {
                status.glucoseDelta = nil
            }
        } else {
            status.latestGlucose = nil
            status.glucoseDelta = nil
        }
    }

    func refreshInsulinData() async {
        do {
            if let latestBolus = try await doseStore.getLatestBolus() {
                status.lastBolusDate = max(status.lastBolusDate ?? .distantPast, latestBolus.startDate)
            }
        } catch {
            log.error("Unable to fetch insulin data: %{public}@", userDetails.id, error.localizedDescription)
        }
    }

    func refreshMealData() async {
        do {
            if let latestCarbEntry = try await carbStore.fetchLatestCarbEntry() {
                status.lastCarbDate =  max(status.lastCarbDate ?? .distantPast, latestCarbEntry.startDate)
            }
        } catch {
            log.error("Unable to fetch carb data: %{public}@", userDetails.id, error.localizedDescription)
        }
    }

    // MARK: - Remote data
    func fetchRemoteData(api: TAPI) async {
        self.isLoading = true
        let now = Date()
        // Fetch at most 6 hours of data
        let backfillInterval = min(now.timeIntervalSince(status.lastRefresh), .hours(6)) + .minutes(10)
        let start = now.addingTimeInterval(-backfillInterval)
        let filter = TDatum.Filter(startDate: start, types: ["cbg", "basal", "bolus", "insulin", "food", "dosingDecision", "pumpStatus", "controllerStatus"])
        do {
            let (data, _) = try await api.listData(filter: filter, userId: userDetails.id)

            status.lastRefresh = Date()

            delegate?.stateDidChange(for: self)

            var newSamples = [NewGlucoseSample]()
            var newDoses = [DoseEntry]()
            var newCarbEntries = [SyncCarbObject]()
            var newDosingDecisions = [StoredDosingDecision]()

            for datum in data {
                switch datum {
                case let cbg as TCBGDatum:
                    if let sample = cbg.newGlucoseSample {
                        newSamples.append(sample)
                    }
                case let basal as TAutomatedBasalDatum:
                    if let dose = basal.dose {
                        newDoses.append(dose)
                    }
                case let bolus as TAutomatedBolusDatum:
                    if let dose = bolus.dose {
                        newDoses.append(dose)
                    }
                case let bolus as TNormalBolusDatum:
                    if let dose = bolus.dose {
                        newDoses.append(dose)
                    }
                case let food as TFoodDatum:
                    if let carbEntry = food.syncCarbObject {
                        newCarbEntries.append(carbEntry)
                    }
                case let dosingDecision as TDosingDecisionDatum:
                    if let storedDosingDecision = dosingDecision.storedDosingDecision {
                        newDosingDecisions.append(storedDosingDecision)
                    }
                case let pumpStatus as TPumpStatusDatum:
                    handlePumpStatus(pumpStatus: pumpStatus)
                default:
                    print("Unhandled: \(datum)")
                    break
                }
            }
            if !newSamples.isEmpty {
                glucoseStore.addGlucoseSamples(newSamples) { result in }
            }
            if !newDoses.isEmpty {
                doseStore.addDoses(newDoses, from: nil) { error in }
                Task {
                    await self.refreshInsulinData()
                }
            }
            if !newCarbEntries.isEmpty {
                carbStore.setSyncCarbObjects(newCarbEntries) { error in }
                Task {
                    await self.refreshMealData()
                }
            }
            if !newDosingDecisions.isEmpty {
                dosingDecisionStore.addStoredDosingDecisions(dosingDecisions: newDosingDecisions) { error in }
                Task {
                    await getLatestDosingDecision()
                }
            }
        } catch {
            log.error("Unable to fetch data for %{public}@: %{public}@", userDetails.id, error.localizedDescription)
        }
        self.isLoading = false
    }

    private func handlePumpStatus(pumpStatus: TPumpStatusDatum) {
        guard let time = pumpStatus.time, let basalDelivery = pumpStatus.basalDelivery else {
            return
        }
        let lastBasalStateTime = status.basalState?.date ?? .distantPast

        let rate: Double
        let isSuspended: Bool
        let scheduledRate: Double = 1.23 // TODO: lookup current rate in settings schedule
        switch basalDelivery.state {
        case .none:
            return
        case .cancelingTemporary, .initiatingTemporary, .resuming, .suspending, .scheduled:
            rate = scheduledRate
            isSuspended = false
        case .some(.suspended):
            rate = 0
            isSuspended = true
        case .some(.temporary):
            guard let dose = basalDelivery.dose, let doseRate = dose.rate else { return }
            rate = doseRate
            isSuspended = false
        }

        if time > lastBasalStateTime {
            status.basalState = BasalDeliveryState(
                date: time,
                rate: rate,
                scheduledRate: scheduledRate,
                isSuspended: isSuspended)
        }
    }
}
