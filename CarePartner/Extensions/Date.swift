//
//  Date.swift
//  CarePartner
//
//  Created by Pete Schwamb on 6/2/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

extension Date {

    private static let timeFormatter: ISO8601DateFormatter = {
        var timeFormatter = ISO8601DateFormatter()
        timeFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return timeFormatter
    }()

    private static let timeFormatterAlternate: ISO8601DateFormatter = {
        var timeFormatter = ISO8601DateFormatter()
        timeFormatter.formatOptions = [.withInternetDateTime]
        return timeFormatter
    }()

    init?(jsonString: String) {
        if let date = Date.timeFormatter.date(from: jsonString) {
            self = date.roundedToTimeInterval(.milliseconds(1))
        } else if let date = Date.timeFormatterAlternate.date(from: jsonString) {
            self = date.roundedToTimeInterval(.milliseconds(1))
        } else {
            return nil
        }
    }

    private func roundedToTimeInterval(_ interval: TimeInterval) -> Date {
        guard interval != 0 else {
            return self
        }
        return Date(timeIntervalSinceReferenceDate: round(self.timeIntervalSinceReferenceDate / interval) * interval)
    }
}
