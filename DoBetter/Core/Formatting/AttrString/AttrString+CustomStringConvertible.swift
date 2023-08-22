//
// Created by Artem Rylov on 17.02.2022.
// Copyright (c) 2022 vision-invest. All rights reserved.
//

import Foundation
import UIKit

extension AttrString: CustomStringConvertible {
    public var description: String { _descriptionString(string: string, attributes: attributes) }
}

extension AttrString.StringInterpolation: CustomStringConvertible {
    public var description: String { _descriptionString(string: string, attributes: attributes) }
}

private func _descriptionString(preamble: String? = nil, string: String, attributes: [AttrString.RangedAttribute]) -> String {
    var description: String = preamble ?? "" + string + "\n"
    attributes.forEach {
        description += _printableSizeLine(offset: preamble?.count ?? 0,
                                          start: $0.range.lowerBound,
                                          end: $0.range.upperBound,
                                          description: "\($0.attribute)")
    }
    return description
}

private func _printableSizeLine(offset: Int, start: Int, end: Int, description: String) -> String {
    var string = String()

    let preambleLength = start + offset - 1
    if preambleLength > 0 {
        for i in 0...preambleLength { string.append(" ") }
    }
    string.append("|")

    let fillerLength = end - start - 3
    if fillerLength > 0 {
        for i in 0...(fillerLength > 0 ? fillerLength : 0) { string.append("-") }
    }
    string.append("|\t\(description)\n")
    return string
}
