//
//  GlucoseTrend.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/30/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation
import LoopKit
import UIKit
import SwiftUI

extension GlucoseTrend {
    public var image: Image {
        switch self {
        case .upUpUp:
            return Image("arrow.double.up.circle")
        case .upUp:
            return Image(systemName: "arrow.up.circle")
        case .up:
            return Image(systemName: "arrow.up.right.circle")
        case .flat:
            return Image(systemName: "arrow.right.circle")
        case .down:
            return Image(systemName: "arrow.down.right.circle")
        case .downDown:
            return Image(systemName: "arrow.down.circle")
        case .downDownDown:
            return Image("arrow.double.down.circle")
        }
    }

    public var filledImage: Image {
        switch self {
        case .upUpUp:
            return Image("arrow.double.up.fill")
        case .upUp:
            return Image(systemName: "arrow.up.circle.fill")
        case .up:
            return Image(systemName: "arrow.up.right.circle.fill")
        case .flat:
            return Image(systemName: "arrow.right.circle.fill")
        case .down:
            return Image(systemName: "arrow.down.right.circle.fill")
        case .downDown:
            return Image(systemName: "arrow.down.circle.fill")
        case .downDownDown:
            return Image("arrow.double.down.fill")
        }
    }

}
