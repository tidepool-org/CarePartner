//
//  OnboardingContent.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/18/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

/// Wraps any `View` in a container to be used in the onboarding flow
struct OnboardingContent<Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    private let title: Text
    private let content: Content
    private let onboardingLink: OnboardingLink
    
    /// Instantiates an ``OnboardingContent`` `View`
    /// - Parameters:
    ///   - title: The textual title of the pages content
    ///   - content: Any SwiftUI `View` to be placed below the title
    ///   - onboardingLink: Call to action that floats above the page's content
    init(
        _ title: Text,
        @ViewBuilder content: () -> Content,
        @ViewBuilder onboardingLink: () -> OnboardingLink
    ) {
        self.title = title
        self.content = content()
        self.onboardingLink = onboardingLink()
    }
    
    private var onboardingLinkBackground: Color {
        switch colorScheme {
        case .light:
            return .white
        case .dark:
            return Color("accent-background").opacity(0.2)
        @unknown default:
            return .white
        }
    }
    
    private var shadowColor: Color {
        switch colorScheme {
        case .light:
            return .black.opacity(0.1)
        case .dark:
            return .clear
        @unknown default:
            return .black.opacity(0.1)
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 48) {
                    title
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        content
                            .padding(.horizontal, 32)
                    }
                }
                .padding(.bottom, 32)
                .padding(.top, 42)
            }
            
            onboardingLink
                .padding(16)
                .background {
                    onboardingLinkBackground
                        .ignoresSafeArea(edges: .all)
                        .shadow(color: shadowColor, radius: 8, y: -4)
                }
        }
        .background {
            LinearGradient(gradient: Gradient(colors: [Color("accent-background"), Color.clear]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(edges: .all)
        }
    }
}

extension Image {
    /// Use on images within an ``OnboardingContent`` block to make the image full-width
    func onboardingFullWidth() -> some View {
        self
            .resizable()
            .padding(.horizontal, -32)
    }
}

struct OnboardingContent_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContent(Text("Onboarding Content"), content: {}, onboardingLink: { OnboardingLink(.finish, action: {}) })
    }
}
