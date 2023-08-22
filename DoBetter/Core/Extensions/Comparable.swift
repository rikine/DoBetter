//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

/// `Greater than` operator; value always greater than nil
infix operator >?: ComparisonPrecedence

/// `Less than` operator; value always greater than nil
infix operator <?: ComparisonPrecedence

/// `Greater than or equal` operator; value always greater than nil
infix operator >=?: ComparisonPrecedence

/// `Less than or equal` operator; value always greater than nil
infix operator <=?: ComparisonPrecedence

public extension Comparable {

    func clamped(_ minValue: Self?, _ maxValue: Self?) -> Self {
        var value = self
        if let min = minValue {
            value = max(min, self)
        }
        if let max = maxValue {
            value = min(max, value)
        }
        return value
    }

    /// `Greater than` operator; value always greater than nil
    static func >? (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs = lhs else { return false }
        return lhs > rhs
    }

    /// `Greater than` operator; value always greater than nil
    static func >? (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs = rhs else { return true }
        return lhs > rhs
    }

    /// `Less than` operator; value always greater than nil
    static func <? (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs = lhs else { return true }
        return lhs < rhs
    }

    /// `Less than` operator; value always greater than nil
    static func <? (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs = rhs else { return false }
        return lhs < rhs
    }

    /// `Greater than or equal` operator; value always greater than nil
    static func >=? (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs = lhs else { return false }
        return lhs >= rhs
    }

    /// `Greater than or equal` operator; value always greater than nil
    static func >=? (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs = rhs else { return true }
        return lhs >= rhs
    }

    /// `Less than or equal` operator; value always greater than nil
    static func <=? (lhs: Self?, rhs: Self) -> Bool {
        guard let lhs = lhs else { return true }
        return lhs <= rhs
    }

    /// `Less than or equal` operator; value always greater than nil
    static func <=? (lhs: Self, rhs: Self?) -> Bool {
        guard let rhs = rhs else { return false }
        return lhs <= rhs
    }
}
