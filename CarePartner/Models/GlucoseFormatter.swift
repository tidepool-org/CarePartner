//
//  GlucoseFormatter.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/27/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import LoopKit
import SwiftUI

private struct GlucoseFormatterKey: EnvironmentKey {
    static let defaultValue: QuantityFormatter = QuantityFormatter(for: .milligramsPerDeciliter)
}

public extension EnvironmentValues {
    var glucoseFormatter: QuantityFormatter {
        get { self[GlucoseFormatterKey.self] }
        set { self[GlucoseFormatterKey.self] = newValue }
    }
}
