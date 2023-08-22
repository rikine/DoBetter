//
// Created by Vasiliy Samarin on 01.03.2022.
// Copyright (c) 2022 vision-invest. All rights reserved.
//

import Foundation

public extension Optional where Wrapped == AttrString {
    func interpolated() -> NSMutableAttributedString? { map { $0.interpolated() } }

    func apply(textStyle: TextStyle) -> Self { map { $0.apply(textStyle: textStyle) } }
}

public extension Optional where Wrapped == String {
    var attrString: AttrString {
        switch self {
        case .some(let value):
            return value.attrString
        case .none:
            return "-".attrString
        }
    }
}
