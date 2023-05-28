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
            return displayGlucosePreference.format(glucose.quantity)
        } else {
            return "---"
        }
    }

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "person.fill")
                    Text(followee.status.name)
                        .font(.headline)
                }
                Spacer()
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("12:34")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .padding(5)
            }
            .padding(.top, 8)

            HStack {

                Text(glucoseText)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.background)
                    .frame(height: 44)
                    .cornerRadius(22)
                LoopCircleView(closeLoop: true, lastLoopCompleted: Date(), dataIsStale: false)
                    .padding(20)
                Text("0.45 U/hr")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.background)
                    .frame(height: 44)
                    .cornerRadius(22)
            }
        }
        .padding(.horizontal, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)

    }
}

struct FolloweeSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            FolloweeStatusView(followee: Followee.mock)
        }
    }
}
