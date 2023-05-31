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

    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference

    @ObservedObject private var followee: Followee

    @State private var expanded: Bool = true

    init(followee: Followee) {
        self.followee = followee
    }

    var glucoseText: String {
        if let glucose = followee.status.latestGlucose {
            return displayGlucosePreference.format(glucose.quantity, includeUnit: false)
        } else {
            return "---"
        }
    }

    var glucoseUnits: String {
        return displayGlucosePreference.formatter.localizedUnitStringWithPlurality()
    }

    var body: some View {
        VStack {
            statusHeader
                .padding(.vertical, 10)
            pillRow
                .padding(.bottom, 12)
            if expanded {
                details
                    .padding(.bottom)

            }
        }
        .padding(.horizontal, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)

    }

    var pillRow: some View {
        HStack(spacing: 12) {
            cgmStatus
            LoopCircleView(closeLoop: true, lastLoopCompleted: Date(), dataIsStale: false)
                .animation(Animation.easeInOut(duration: 2), value: 5)
            Text("1.5 U/hr")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.background)
                .frame(height: 44)
                .cornerRadius(22)
        }
    }

    var statusHeader: some View {
        HStack(spacing: 0) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .fontWeight(.light)
                Text(followee.status.name)
                    .font(.headline)

                Spacer()
            }
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text(followee.status.lastRefresh, style: .time)
            }
            .font(.caption)
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
            return signText + displayGlucosePreference.format(delta, includeUnit: false)
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

    var insulinDetail: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Active Insulin")
                Text("Last Bolus: ")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("4.35 U")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.insulin)
        }
    }

    var carbDetail: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Active Carbs")
                Text("Last Entry: 3 mins ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("25 g")
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
                        name: "Sally",
                        latestGlucose: StoredGlucoseSample.mock(150, .downDown),
                        glucoseDelta: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: -10),
                        lastRefresh: Date()
                    )
                )
            )
            .environmentObject(DisplayGlucosePreference(displayGlucoseUnit: .millimolesPerLiter))
        }
    }
}
