//
//  LoopCompletionFreshness.swift
//  CarePartner
//
//  Created by Pete Schwamb on 3/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

public enum LoopCompletionFreshness {
    case fresh
    case aging
    case stale

    public var maxAge: TimeInterval? {
        switch self {
        case .fresh:
            return TimeInterval(minutes: 6)
        case .aging:
            return TimeInterval(minutes: 16)
        case .stale:
            return nil
        }
    }

    public init(age: TimeInterval?) {
        guard let age = age else {
            self = .stale
            return
        }

        switch age {
        case let t where t <= LoopCompletionFreshness.fresh.maxAge!:
            self = .fresh
        case let t where t <= LoopCompletionFreshness.aging.maxAge!:
            self = .aging
        default:
            self = .stale
        }
    }

    public init(lastCompletion: Date?, at date: Date = Date()) {
        guard let lastCompletion = lastCompletion else {
            self = .stale
            return
        }

        self = LoopCompletionFreshness(age: date.timeIntervalSince(lastCompletion))
    }

}
