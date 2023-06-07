//
//  Sequence.swift
//  CarePartner
//
//  Created by Pete Schwamb on 5/30/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

extension Sequence {
    // Sorts in ascending order
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
