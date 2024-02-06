//
//  AccountView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 3/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import HealthKit

struct FolloweeStatusView: View {

    @EnvironmentObject private var formatters: QuantityFormatters

    @ObservedObject private var followee: Followee

    @State private var expanded: Bool

    init(followee: Followee, initiallyExpanded: Bool) {
        self.followee = followee
        self.expanded = initiallyExpanded
    }

    var body: some View {
        VStack(spacing: 12) {
            statusHeader
            
            pillRow
            
            if expanded {
                details
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground).cornerRadius(18))
        .padding()
    }

    var pillRow: some View {
        HStack(spacing: 12) {
            cgmStatus
            LoopCircleView(closeLoop: true, lastLoopCompleted: Date(), dataIsStale: false)
                .animation(Animation.easeInOut(duration: 2), value: 5)
            pumpStatus
        }
    }

    var basalRateText: String {
        if let rate = followee.status.basalState?.rate {
            let quantity = HKQuantity(unit: .internationalUnitsPerHour, doubleValue: rate)
            return formatters.insulinRateFormatter.string(from: quantity, includeUnit: false)!

        } else {
            return "-"
        }
    }

    var pumpStatus: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(basalRateText)
                .font(.system(size: 30))
                .fontWeight(.black)
                .foregroundColor(.insulin)
            Text("U/hr")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .frame(height: 44)
        .cornerRadius(22)
    }

    var statusHeader: some View {
        HStack(spacing: 0) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .fontWeight(.light)
                Text(followee.status.firstName)
                    .font(.headline)

                Spacer()
            }
            ZStack {
                ProgressView()
                    .opacity(followee.isLoading ? 1 : 0)
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text(followee.status.lastRefresh, style: .time)
                }
                .opacity(followee.isLoading ? 0 : 1)
                .font(.caption)
            }
            .animation(.easeIn, value: followee.isLoading)
            .foregroundColor(.secondary)
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        expanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .rotationEffect(Angle(degrees: expanded ? 90 : 0))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    var glucoseText: String {
        if let glucose = followee.status.latestGlucose {
            return formatters.glucoseFormatter.string(from: glucose.quantity, includeUnit: false)!
        } else {
            return "---"
        }
    }

    var glucoseUnits: String {
        return formatters.glucoseFormatter.localizedUnitStringWithPlurality()
    }

    var cgmStatus: some View {
        HStack {
            VStack {
                Text(glucoseText)
                    .font(.system(size: 30))
                    .fontWeight(.black)
                    .padding(.top, 5)
                Text(glucoseUnits)
                    .font(.caption)
                    .padding(.top, -25)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            if let trend = followee.status.latestGlucose?.trend {
                trend.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                    .padding(.trailing, -8)
                    .foregroundColor(.glucose)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .frame(height: 44)
        .cornerRadius(22)
    }

    var details: some View {
        VStack(alignment: .leading) {
            glucoseDetail
                .padding(.horizontal)
                .padding(.top)
            Divider()
                .padding(.leading)
            insulinDetail
                .padding(.horizontal)
            Divider()
                .padding(.leading)
            carbDetail
                .padding(.horizontal)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(.background)
        .cornerRadius(10)
    }

    var deltaText: String {
        if let delta = followee.status.glucoseDelta {
            var signText: String
            if delta.doubleValue(for: .milligramsPerDeciliter) >= 0 {
                signText = NSLocalizedString("+", comment: "Sign marker for positive glucose delta")
            } else {
                signText = ""
            }
            return signText + formatters.glucoseFormatter.string(from: delta, includeUnit: false)!
        } else {
            return NSLocalizedString("-", comment: "Placeholder when glucose delta is not available")
        }
    }

    var glucoseAgeText: String {
        if let latest = followee.status.latestGlucose {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: latest.startDate, relativeTo: Date())
        } else {
            return ""
        }
    }

    var glucoseDetail: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Change in Glucose")
                HStack(spacing: 0) {
                    Text("Last Reading: ")
                    Text(glucoseAgeText)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Text(deltaText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.glucose)
        }
    }

    var bolusAgeText: String {
        if let latest = followee.status.lastBolusDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: latest, relativeTo: Date())
        } else {
            return ""
        }
    }

    var activeInsulinText: String {
        if let iob = followee.status.activeInsulin {
            let quantity = HKQuantity(unit: .internationalUnit(), doubleValue: iob.value)
            return formatters.insulinFormatter.string(from: quantity)!
        } else {
            return "-"
        }
    }

    var insulinDetail: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Active Insulin")
                HStack(spacing: 0) {
                    Text("Last Bolus: ")
                    Text(bolusAgeText)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Text(activeInsulinText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.insulin)
        }
    }

    var carbAgeText: String {
        if let latest = followee.status.lastCarbDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: latest, relativeTo: Date())
        } else {
            return ""
        }
    }

    var activeCarbsText: String {
        if let cob = followee.status.activeCarbs {
            return formatters.carbFormatter.string(from: cob.quantity)!
        } else {
            return "-"
        }
    }

    var carbDetail: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Active Carbs")
                HStack(spacing: 0) {
                    Text("Last Entry: ")
                    Text(carbAgeText)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Text(activeCarbsText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.carbs)
        }
    }
}

struct FolloweeSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            FolloweeStatusView(
                followee: FolloweeMock(
                    status: FolloweeStatus(
                        firstName: "Sally",
                        lastRefresh: Date(),
                        latestGlucose: StoredGlucoseSample.mock(150, .downDown),
                        glucoseDelta: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: -10),
                        activeInsulin: InsulinValue(startDate: Date(), value: 1.056),
                        activeCarbs: CarbValue(startDate: Date(), value: 25),
                        basalState: BasalDeliveryState(date: Date(), rate: 2.55, scheduledRate: 1.0, isSuspended: false),
                        lastBolusDate: Date().addingTimeInterval(-8*60),
                        lastCarbDate: Date().addingTimeInterval(-4*60*60)
                    ),
                    triggerLoading: true
                ),
                initiallyExpanded: true
            )
            .environmentObject(QuantityFormatters(glucoseUnit: .milligramsPerDeciliter))
        }
    }
}
