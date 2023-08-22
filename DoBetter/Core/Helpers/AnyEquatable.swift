//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

import Foundation

public protocol AnyEquatable {
    func isEqual(to other: AnyEquatable?) -> Bool
}

public extension AnyEquatable where Self: Equatable {
    func isEqual(to other: AnyEquatable?) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }

    var anyEquatable: AnyEquatable {
        self
    }
}

public extension Collection where Element: AnyEquatable {
    func isEqual<T: AnyEquatable>(to other: [T]) -> Bool {
        self.elementsEqual(other) {
            $0.isEqual(to: $1)
        }
    }
}

public struct AnyEquatableNil: AnyEquatable, Equatable {
    public init() {}
    public static func ==(lhs: AnyEquatableNil, rhs: AnyEquatableNil) -> Bool { true }
}

public struct AnyNonEquatableNil: AnyEquatable, Equatable {
    public init() {}
    public static func ==(lhs: AnyNonEquatableNil, rhs: AnyNonEquatableNil) -> Bool { false }
}

public extension Optional where Wrapped: AnyEquatable {
    func isEqual(to other: AnyEquatable?) -> Bool {
        if let self = self,
           let other = other {
            return self.isEqual(to: other)
        } else {
            return self == nil && other == nil
        }
    }
}

extension String: AnyEquatable {}

extension Optional {
    var anyEquatable: AnyEquatable {
        switch self {
        case .some(let value):
            guard let value = value as? AnyEquatable else {
                return guardUnreachable(AnyNonEquatableNil())
            }
            return value
        case .none:
            return AnyEquatableNil()
        }
    }
}
