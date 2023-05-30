//
//  LoopCircleView.swift
//  Loop
//
//  Created by Noah Brauner on 8/15/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import SwiftUI

struct LoopCircleView: View {
    let closeLoop: Bool
    let lastLoopCompleted: Date?
    let dataIsStale: Bool

    var body: some View {
        let closeLoop = closeLoop
        let lastLoopCompleted = lastLoopCompleted ?? Date().addingTimeInterval(.minutes(16))
        let age = abs(min(0, lastLoopCompleted.timeIntervalSinceNow))
        let freshness = LoopCompletionFreshness(age: age)

        let loopColor = getLoopColor(freshness: freshness)

        Circle()
            .trim(from: closeLoop ? 0 : 0.2, to: 1)
            .stroke(dataIsStale ? Color(UIColor.systemGray3) : loopColor, lineWidth: 8)
            .rotationEffect(Angle(degrees: -126))
            .frame(width: 36, height: 36)
    }

    func getLoopColor(freshness: LoopCompletionFreshness) -> Color {
        switch freshness {
        case .fresh:
            return .fresh
        case .aging:
            return .warning
        case .stale:
            return .stale
        }
    }
}
