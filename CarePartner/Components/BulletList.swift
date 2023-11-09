//
//  BulletList.swift
//  CarePartner
//
//  Created by Cameron Ingham on 10/18/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

/// Determines the ``Bullet`` rendering style
enum BulletStyle {
    /// Standard bulleted list item
    case `default`
    
    /// ``Bullet`` containing an incrementing number
    case incrementing
}

/// Defines a pre-styled bullet to be used in a ``BulletList``
struct Bullet: View, Identifiable {
    
    fileprivate var style: BulletStyle = .default

    fileprivate var index: Int = 0
    
    private let text: Text
    
    var id: Int {
        index
    }
    
    /// Instantiates a ``Bullet`` with `Text`
    /// - Parameter text: The textual content of the ``Bullet``
    init(_ text: Text) {
        self.text = text
    }
    
    /// Instantiates a ``Bullet`` with a non-localized `String`
    /// - Parameter content: The verbatim content of the ``Bullet``
    init(verbatim content: String) {
        self.text = Text(verbatim: content)
    }
    
    /// Instantiates a ``Bullet`` with any `StringProtocol`
    /// - Parameter value: The `String` content of the ``Bullet``
    init(_ value: any StringProtocol) {
        self.text = Text(value)
    }
    
    /// Instantiates a ``Bullet`` with a localized `String`
    /// - Parameters:
    ///   - key: The key for a string in the table identified by `tableName`.
    ///   - tableName: The name of the string table to search. If `nil`, use the
    ///     table in the `Localizable.strings` file.
    ///   - bundle: The bundle containing the strings file. If `nil`, use the
    ///     main bundle.
    ///   - comment: Contextual information about this key-value pair.
    init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.text = Text(
            key,
            tableName: tableName,
            bundle: bundle,
            comment: comment
        )
    }
    
    var body: some View {
        HStack(spacing: 16) {
            switch style {
            case .default:
                Color.accentColor
                    .opacity(0.5)
                    .clipShape(Circle())
                    .frame(width: 8, height: 8)
            case .incrementing:
                Text("\(index)")
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .background {
                        Color.accentColor
                            .clipShape(Circle())
                            .frame(width: 21, height: 21)
                    }
            }
            
            text
        }
    }
}

@resultBuilder
struct BulletListBuilder {
    static func buildBlock(_ components: Bullet...) -> [Bullet] {
        return components
    }
}

/// Composes a set of ``Bullet``s into a pre-styled list
struct BulletList: View {
    
    private let items: [Bullet]
    
    private let style: BulletStyle
    
    /// Instantiates a ``BulletList`` with an optional ``BulletStyle`` and a list of ``Bullet``s
    /// - Parameters:
    ///   - style: The rendering style of the ``Bullet``s
    ///   - items: The list of ``Bullet``s
    init(
        _ style: BulletStyle = .default,
        @BulletListBuilder items: () -> [Bullet]
    ) {
        self.style = style
        self.items = items()
            .enumerated()
            .map { enumeratedItem in
                var item = enumeratedItem.element
                item.index = enumeratedItem.offset + 1
                item.style = style
                return item
            }
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: style == .default ? 4 : 16
        ) {
            ForEach(items, id: \.id) { item in
                item
            }
        }
    }
}


struct BulletList_Previews: PreviewProvider {
    static var previews: some View {
        BulletList {
            Bullet("Bullet 1")
            Bullet("Bullet 2")
            Bullet("Bullet 3")
            Bullet("Bullet 4")
            Bullet("Bullet 5")
            Bullet("Bullet 6")
            Bullet("Bullet 7")
            Bullet("Bullet 8")
        }
    }
}
