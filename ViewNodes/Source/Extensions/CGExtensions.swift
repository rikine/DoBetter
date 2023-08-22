//
// Created by Maxime Tenth on 10/15/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    public var size: CGSize {
        CGSize(width: left + right,
               height: top + bottom)
    }

    static public func all(_ size: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: size, left: size, bottom: size, right: size)
    }

    static public func left(_ size: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: size, bottom: 0, right: 0)
    }

    static public func top(_ size: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: size, left: 0, bottom: 0, right: 0)
    }

    static public func right(_ size: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: size)
    }

    static public func bottom(_ size: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: size, right: 0)
    }

    public func left(_ size: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.left = size
        return insets
    }

    public func top(_ size: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.top = size
        return insets
    }

    public func right(_ size: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.right = size
        return insets
    }

    public func bottom(_ size: CGFloat) -> UIEdgeInsets {
        var insets = self
        insets.bottom = size
        return insets
    }

    public func negate() -> UIEdgeInsets {
        UIEdgeInsets(top: -top,
                     left: -left,
                     bottom: -bottom,
                     right: -right)
    }

    static public func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(top: lhs.top + rhs.top,
                     left: lhs.left + rhs.left,
                     bottom: lhs.bottom + rhs.bottom,
                     right: lhs.right + rhs.right)
    }

}

extension CGSize {

    public var rect: CGRect {
        CGRect(origin: .zero, size: self)
    }

    static public func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width,
               height: lhs.height + rhs.height)
    }

    static public func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width,
               height: lhs.height - rhs.height)
    }

    static public func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = CGSize(width: lhs.width + rhs.width,
                     height: lhs.height + rhs.height)
    }

    static public func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = CGSize(width: lhs.width - rhs.width,
                     height: lhs.height - rhs.height)
    }

    public func rounded(_ rule: FloatingPointRoundingRule) -> CGSize {
        CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }

    public var point: CGPoint {
        CGPoint(x: width, y: height)
    }
}

extension CGPoint {

    static public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x,
                y: lhs.y + rhs.y)
    }

    static public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x,
                y: lhs.y - rhs.y)
    }

    static public func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x * rhs.x,
                y: lhs.y * rhs.y)
    }

    static public func /(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x / rhs.x,
                y: lhs.y / rhs.y)
    }

    static public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs,
                y: lhs.y * rhs)
    }

    static public func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs,
                y: lhs.y / rhs)
    }

    static public func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x + rhs.x,
                      y: lhs.y + rhs.y)
    }

    static public func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x - rhs.x,
                      y: lhs.y - rhs.y)
    }
}

extension CGPoint {
    static public let topLeft = CGPoint(x: 0, y: 0)
    static public let top = CGPoint(x: 0.5, y: 0)
    static public let topRight = CGPoint(x: 1, y: 0)
    static public let left = CGPoint(x: 0, y: 0.5)
    static public let right = CGPoint(x: 1, y: 0.5)
    static public let bottomLeft = CGPoint(x: 0, y: 1)
    static public let bottom = CGPoint(x: 0.5, y: 1)
    static public let bottomRight = CGPoint(x: 1, y: 1)
    static public let center = CGPoint(x: 0.5, y: 0.5)
}

extension Int {
    public var px: CGFloat {
        CGFloat(self) / UIScreen.main.scale
    }
}

extension CGRect {
    func applyingTransformAnchorPointCenter(_ transform: CGAffineTransform) -> CGRect {
        guard transform != .identity else {
            return self
        }
        var transformed = applying(transform)
        transformed.origin += (size - transformed.size).point / 2 + origin - (origin * transform.scale)
        return transformed

    }

    public func applying(transform: CGAffineTransform, anchorPoint: CGPoint) -> CGRect {
        fatalError("not implemented")
    }

    /// Increase CGRect all edges wth given padding
    ///
    /// Instead of .inset(by insets: UIEdgeInsets) -> CGRect positive insets values increase final rect area
    ///
    /// - Parameter padding:
    /// - Returns:
    public func increase(by padding: UIEdgeInsets) -> CGRect {
        .init(origin: origin - CGPoint(x: padding.left, y: padding.top),
              size: size + CGSize(width: padding.left + padding.right,
                                  height: padding.top + padding.bottom))
    }
}

extension CGAffineTransform {
    var scale: CGPoint {
        CGPoint(x: sqrt(a * a + c * c),
                y: sqrt(b * b + d * d))
    }

    static func identity(scaled: CGFloat) -> CGAffineTransform {
        CGAffineTransform.identity.scaledBy(x: scaled, y: scaled)
    }
}

extension UIRectCorner {
    var cornerMask: CACornerMask {
        var cornerMask = CACornerMask()
        if contains(.topLeft) {
            cornerMask.insert(.layerMinXMinYCorner)
        }
        if contains(.topRight) {
            cornerMask.insert(.layerMaxXMinYCorner)
        }
        if contains(.bottomLeft) {
            cornerMask.insert(.layerMinXMaxYCorner)
        }
        if contains(.bottomRight) {
            cornerMask.insert(.layerMaxXMaxYCorner)
        }
        return cornerMask
    }
}
