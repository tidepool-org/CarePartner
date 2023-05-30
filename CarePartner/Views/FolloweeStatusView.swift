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

struct FolloweeStatusView: View {

    @EnvironmentObject private var displayGlucosePreference: DisplayGlucosePreference

    @ObservedObject private var followee: Followee

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
                Image(systemName: "person.fill")
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
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
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
                    .foregroundColor(.accentColor)
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .frame(height: 44)
        .cornerRadius(22)
    }
}

struct FolloweeSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            FolloweeStatusView(
                followee: FolloweeMock(
                    status: FolloweeStatus(
                        name: "Sally",
                        latestGlucose: StoredGlucoseSample.mock(150, .downDownDown),
                        lastRefresh: Date()
                    )
                )
            )
            .environmentObject(DisplayGlucosePreference(displayGlucoseUnit: .milligramsPerDeciliter))

        }
    }
}
