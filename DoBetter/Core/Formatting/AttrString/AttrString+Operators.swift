//
// Created by Artem Rylov on 17.02.2022.
// Copyright (c) 2022 vision-invest. All rights reserved.
//

import Foundation
import UIKit

public extension AttrString.StringInterpolation {
    static func +=(left: inout AttrString.StringInterpolation, right: AttrString) {
        // swiftlint:disable shorthand_operator
        left = left + right
    }

    static func +(left: AttrString.StringInterpolation, right: AttrString) -> AttrString.StringInterpolation {
        var newString = AttrString.StringInterpolation()
        newString.string = left.string + right.string
        newString.attachmentStorage = left.attachmentStorage
        newString.attachmentStorage += right.attachmentStorage.map {
            .init(attachableObject: $0.attachableObject, position: $0.position + left.length, attributes: $0.attributes)
        }
        newString.attributes = left.attributes
        newString.attributes += right.attributes.map {
            AttrString.RangedAttribute(attribute: $0.attribute,
                                       range: .init(location: $0.range.location + left.length,
                                                    length: $0.range.length))
        }
        return newString
    }
}

public extension AttrString {
    static func +=(left: inout AttrString, right: AttrString) {
        // swiftlint:disable shorthand_operator
        left = left + right
    }

    static func +(left: AttrString, right: AttrString) -> AttrString {
        var newString = AttrString()
        newString.string = left.string + right.string
        newString.attachmentStorage = left.attachmentStorage
        newString.attachmentStorage += right.attachmentStorage.map {
            .init(attachableObject: $0.attachableObject, position: $0.position + left.length, attributes: $0.attributes)
        }
        newString.attributes = left.attributes
        newString.attributes += right.attributes.map {
            // Если локация не найдена, тогда прибавлять не надо, а так дальше и понесем NSNotFound. (Иначе переполнение Int'а)
            let location = ($0.range.location == NSNotFound)
                ? NSNotFound
                : $0.range.location + left.length
            return RangedAttribute(attribute: $0.attribute,
                                   range: .init(location: location,
                                                length: $0.range.length))
        }
        return newString
    }

    static func +(lhs: AttrString, rhs: IconModel) -> AttrString {
        lhs + rhs.toNewAttrString
    }

    static func +(lhs: AttrString, rhs: IconModel?) -> AttrString {
        guard let rhs else { return lhs }
        return lhs + rhs
    }

    static func +(lhs: IconModel, rhs: AttrString) -> AttrString {
        lhs.toNewAttrString + rhs
    }
}

prefix operator **
prefix operator *!

public prefix func **(_ string: AttrString) -> AttrString { string }

public prefix func *!(_ string: AttrString) -> NSAttributedString { string.interpolated() }

public extension AttrString {
    /// Вариант финализатора через NSAttributedString
    /// Удобно применять в вариант **"строка" * TextStyle()
    ///
    /// **"Съешь \(wrap: "же ещё \(wrap: "эт\(icon: IconModel(glyph: .glyphSBP))их", .color(.blue)) мягких", .color(.red)) булок, да выпей чаю" * .label.multiline
    static func *(lhs: AttrString, rhs: TextStyle) -> NSAttributedString {
        AttrString(lhs, rhs.attributes).interpolated()
    }
}

public extension AttrString {
    static func *(lhs: AttrString, rhs: AttrString.Style) -> NSAttributedString {
        AttrString(lhs, rhs.attributes).interpolated()
    }
}
