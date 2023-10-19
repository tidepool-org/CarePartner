//
//  ClaimsConfirmationView.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/17/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

struct ClaimsConfirmationView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var acceptOpacity: Double {
        colorScheme == .light ? 0.25 : 0.5
    }
    
    private var cancelOpacity: Double {
        colorScheme == .light ? 0.2 : 0.5
    }
    
    var body: some View {
        OnboardingContent(Text("Using the App")) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 66, height: 66)
                .foregroundStyle(Color.accentColor, Color.accentColor.opacity(acceptOpacity))
            
            Text("Tidepool Care Partner is for people who want to stay up to date with the activity of someone they care for with diabetes.")
                .fontWeight(.semibold)
            
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 66, height: 66)
                .foregroundStyle(Color.red, Color.red.opacity(cancelOpacity))
            
            Text("Do not use Tidepool Care Partner for treatment decisions, such as insulin dosing.")
                .fontWeight(.semibold)
            
            Text("The Tidepool Loop user should follow instructions within the Tidepool Loop app.")
        } onboardingLink: {
           OnboardingLink(.iUnderstand, destination: .notifications)
       }
    }
}

struct ClaimsConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ClaimsConfirmationView()
        }
    }
}
