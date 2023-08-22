//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

extension UIEdgeInsets: EdgeInsets {

    func left(_ size: CGFloat) -> Self {
        updated(\.left, with: size)
    }

    func right(_ size: CGFloat) -> Self {
        updated(\.right, with: size)
    }

    static prefix func -(_ insets: UIEdgeInsets) -> Self {
        var insets = insets
        insets.top *= -1
        insets.bottom *= -1
        insets.left *= -1
        insets.right *= -1
        return insets
    }
}

extension NSDirectionalEdgeInsets: EdgeInsets {

    var left: CGFloat { leading }

    var right: CGFloat { trailing }

    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.init(top: top, leading: left, bottom: bottom, trailing: right)
    }

    func left(_ size: CGFloat) -> Self {
        updated(\.leading, with: size)
    }

    func right(_ size: CGFloat) -> Self {
        updated(\.trailing, with: size)
    }
}

protocol EdgeInsets: Updatable {
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

    var left: CGFloat { get }
    var right: CGFloat { get }

    var verticalSum: CGFloat { get }
    var horizontalSum: CGFloat { get }

    var top: CGFloat { get set }
    var bottom: CGFloat { get set }

    static func all(_ size: CGFloat) -> Self
    static func vertical(_ size: CGFloat) -> Self
    static func horizontal(_ size: CGFloat) -> Self
    static func top(_ size: CGFloat) -> Self
    static func bottom(_ size: CGFloat) -> Self
    static func left(_ size: CGFloat) -> Self
    static func right(_ size: CGFloat) -> Self

    func left(_ size: CGFloat) -> Self
    func top(_ size: CGFloat) -> Self
    func right(_ size: CGFloat) -> Self
    func bottom(_ size: CGFloat) -> Self

    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self

    static func +=(lhs: inout Self, rhs: Self)
}

extension EdgeInsets {

    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }

    var verticalSum: CGFloat { top + bottom }

    var horizontalSum: CGFloat { left + right }

    static func vertical(_ size: CGFloat) -> Self {
        Self(top: size, bottom: size)
    }

    static func horizontal(_ size: CGFloat) -> Self {
        Self(left: size, right: size)
    }

    static func all(_ size: CGFloat) -> Self {
        Self(top: size, left: size, bottom: size, right: size)
    }

    static func left(_ size: CGFloat) -> Self {
        Self(left: size)
    }

    static func top(_ size: CGFloat) -> Self {
        Self(top: size)
    }

    static func right(_ size: CGFloat) -> Self {
        Self(right: size)
    }

    static func bottom(_ size: CGFloat) -> Self {
        Self(bottom: size)
    }

    func top(_ size: CGFloat) -> Self {
        updated(\.top, with: size)
    }

    func bottom(_ size: CGFloat) -> Self {
        updated(\.bottom, with: size)
    }

    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(top: lhs.top + rhs.top,
             left: lhs.left + rhs.left,
             bottom: lhs.bottom + rhs.bottom,
             right: lhs.right + rhs.right)
    }

    public static func +=(lhs: inout Self, rhs: Self) {
        // swiftlint:disable shorthand_operator
        lhs = lhs + rhs
    }

    public static func -(lhs: Self, rhs: Self) -> Self {
        Self(top: lhs.top - rhs.top,
             left: lhs.left - rhs.left,
             bottom: lhs.bottom - rhs.bottom,
             right: lhs.right - rhs.right)
    }

    func invertedInsets() -> Self {
        Self(top: -top,
             left: -left,
             bottom: -bottom,
             right: -right)
    }
}
