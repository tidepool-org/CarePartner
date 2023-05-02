//
//  AccountView.swift
//  CarePartner
//
//  Created by Pete Schwamb on 3/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct AccountView: View {

    var accountData: AccountData

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "person.fill")
                    Text(accountData.name)
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

                Text("100 mg/dl")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.background)
                    .frame(height: 44)
                    .cornerRadius(22)
                LoopCircleView(closeLoop: true, lastLoopCompleted: Date(), dataIsStale: false)                                .padding(20)
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
            AccountView(accountData: AccountData.mock)
        }
    }
}
