//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

extension Dictionary {
    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs) { $1 }
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs.merge(rhs) { $1 }
    }
}
