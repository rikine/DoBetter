//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

prefix operator ^^

public prefix func ^^<T>(boxed: T) -> WeakBox<T> { .init(boxed: boxed) }

// FIXME: T: AnyObject
public class WeakBox<T> {

    private weak var _boxed: AnyObject?
    public private(set) var boxed: T? {
        // swiftlint:disable force_cast
        get { _boxed as? T }
        set { _boxed = newValue as AnyObject? }
    }

    public var isEmpty: Bool { get { boxed == nil } }

    public init(boxed: T) {
        self.boxed = boxed
    }

}

extension WeakBox: Equatable, Hashable where T: Hashable {

    public static func ==(lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
        lhs.boxed == rhs.boxed
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(boxed)
    }
}
