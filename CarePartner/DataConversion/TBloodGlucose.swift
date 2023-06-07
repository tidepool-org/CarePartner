//
//  TBloodGlucose.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/31/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit
import HealthKit
import LoopKit

extension TBloodGlucose.Units {
    var hkUnit: HKUnit? {
        switch self {
        case .milligramsPerDeciliter:
            return .milligramsPerDeciliter
        case .millimolesPerLiter:
            return .millimolesPerLiter
        }
    }
}

extension TBloodGlucose.Trend {
    var loopKitTrend: GlucoseTrend {
        switch self {
        case .constant:
            return .flat
        case .slowFall:
            return .down
        case .slowRise:
            return .up
        case .moderateFall:
            return .downDown
        case .moderateRise:
            return .upUp
        case .rapidFall:
            return .downDownDown
        case .rapidRise:
            return .upUpUp
        }
    }
}
