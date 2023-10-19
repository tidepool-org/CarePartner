//
//  OnboardingLink.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/18/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

/// Creates either a `NavigationLink` or `Button` call to action to be used in ``OnboardingContent``
struct OnboardingLink: View {
    
    /// Determines the destination of the `NavigationLink`
    enum Destination {
        /// Routes to ``ClaimsConfirmationView``
        case claimsConfirmation
        
        /// Routes to ``NotificationsView``
        case notifications
        
        /// Routes to ``ManagingFocusModesView``
        case managingFocusModes
    }
    
    /// Determines the content of the ``OnboardingLink``
    enum Label {
        /// Shows "Continue"
        case `continue`
        
        /// Shows "I understand"
        case iUnderstand
        
        /// Shows "Finish"
        case finish
        
        /// Shows a circular progress indicator
        case loading
        
        @ViewBuilder
        fileprivate var title: some View {
            switch self {
            case .continue:
                Text("Continue")
            case .iUnderstand:
                Text("I understand")
            case .finish:
                Text("Finish")
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(width: 16, height: 16)
                    .tint(.white)
            }
        }
    }
    
    @State private var isPerformingAction: Bool = false
    @State private var isDonePerformingAction: Bool = false
    
    private let action: (() async -> Void)?
    private let destination: Destination?
    private let label: Label
    
    /// Instantiates an ``OnboardingLink`` with a ``Destination`` to push on the stack
    /// - Parameters:
    ///   - label: The ``Label`` content of the ``OnboardingLink``
    ///   - destination: The ``Destination`` of the ``OnboardingLink``
    ///   - action: The action to perform when tapped
    init(_ label: Label, destination: Destination, action: (() async -> Void)? = nil) {
        self.label = label
        self.action = action
        self.destination = destination
    }
    
    /// Instantiates an ``OnboardingLink`` with an action to be performed when tapped
    /// - Parameters:
    ///   - label: The ``Label`` content of the ``OnboardingLink``
    ///   - action: The action to perform when tapped
    init(_ label: Label, action: (() async -> Void)? = nil) {
        self.label = label
        self.destination = nil
        self.action = action
    }
    
    var body: some View {
        Group {
            if let destination {
                if let action {
                    Button {
                        isPerformingAction = true

                        Task {
                            await action()
                            isDonePerformingAction = true
                            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                            isPerformingAction = false
                        }

                    } label: {
                        if isPerformingAction {
                            OnboardingLink.Label.loading.title
                        } else {
                            label.title
                        }
                    }
                    .disabled(isPerformingAction)
                    .navigationDestination(isPresented: $isDonePerformingAction) {
                        switch destination {
                        case .claimsConfirmation:
                            ClaimsConfirmationView()
                        case .notifications:
                            NotificationsView()
                        case .managingFocusModes:
                            ManagingFocusModesView()
                        }
                    }
                } else {
                    NavigationLink {
                        switch destination {
                        case .claimsConfirmation:
                            ClaimsConfirmationView()
                        case .notifications:
                            NotificationsView()
                        case .managingFocusModes:
                            ManagingFocusModesView()
                        }
                    } label: {
                        label.title
                    }
                }
            } else {
                Button {
                    isPerformingAction = true
                    
                    Task {
                        await action?()
                        isDonePerformingAction = true
                        isPerformingAction = false
                    }
                } label: {
                    if isPerformingAction {
                        OnboardingLink.Label.loading.title
                    } else {
                        label.title
                    }
                }
                .disabled(isPerformingAction)
            }
        }
        .disabled(label == .loading)
        .buttonStyle(.onboarding)
    }
}


struct OnboardingLink_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Group {
                    Text("Different style options")
                    OnboardingLink(.continue)
                    OnboardingLink(.iUnderstand)
                    OnboardingLink(.finish)
                    OnboardingLink(.loading)
                    
                    Divider().padding(.vertical)
                }
                
                Group {
                    Text("Continue to destination after async work")
                    OnboardingLink(.continue, destination: .claimsConfirmation) {
                        try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                    }
                    
                    Divider().padding(.vertical)
                }
                
                Group {
                    Text("I understand and perform async work")
                    OnboardingLink(.iUnderstand) {
                        try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                        print("Async")
                    }
                    
                    Divider().padding(.vertical)
                }
                
                Group {
                    Text("Finish with non async work")
                    OnboardingLink(.finish) {
                        print("No Async")
                    }
                }
            }
            .padding()
        }
    }
}
