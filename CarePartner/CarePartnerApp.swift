//
//  CarePartnerApp.swift
//  CarePartner
//
//  Created by Pete Schwamb on 2/21/23.
//

import SwiftUI

@main
@MainActor
struct CarePartnerApp: App {

    let summaryViewModel = SummaryViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SummaryView(viewModel: summaryViewModel)
            }
        }
    }
}
