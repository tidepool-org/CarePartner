//
//  OnboardingButtonStyle.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/18/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

/// `ButtonStyle` to be used in the onboarding flow
struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .fontWeight(.semibold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

extension ButtonStyle where Self == OnboardingButtonStyle {
    /// `ButtonStyle` to be used in the onboarding flow
    static var onboarding: Self { OnboardingButtonStyle() }
}

struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Primary Button Style") {}
            .buttonStyle(.onboarding)
            .padding()
    }
}
