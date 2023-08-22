//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import ViewNodes
import UIKit

public extension IconModel {

    struct Shape: Equatable {

        public var size: CGSize
        public var smoothing: CGFloat?

        public init(size: CGSize, smoothing: CGFloat?) {
            self.size = size
            self.smoothing = smoothing
        }

        public static let badgeSize = CGSize.square(20)
        public static let smallSize = CGSize.square(24)
        public static let mediumSize = CGSize.square(32)
        public static let regularSize = CGSize.square(40)
        public static let bigSize = CGSize.square(56)
        public static let largeSize = CGSize.square(80)

        public static let largeSquircle = squircleOf(size: largeSize)
        public static let largeCircle = circleOf(size: largeSize)
        public static let bigSquircle = squircleOf(size: bigSize)
        public static let bigCircle = circleOf(size: bigSize)
        public static let squircle = squircleOf(size: regularSize)
        public static let badgeCircle = circleOf(size: badgeSize)
        public static let circle = circleOf(size: regularSize)
        public static let smallCircle = circleOf(size: smallSize)
        public static let smallSquircle = squircleOf(size: smallSize)
        public static let mediumCircle = circleOf(size: mediumSize)
        public static let mediumSquircle = squircleOf(size: mediumSize)

        public static func squircleOf(size: CGSize) -> Shape {
            Shape(size: size, smoothing: 0.777)
        }

        public static func circleOf(size: CGSize) -> Shape {
            Shape(size: size, smoothing: nil)
        }

        public static func squircleOf(size: CGFloat) -> Shape {
            squircleOf(size: CGSize(width: size, height: size))
        }

        public static func circleOf(size: CGFloat) -> Shape {
            circleOf(size: CGSize(width: size, height: size))
        }

        public func path(with padding: UIEdgeInsets, borderWidth: CGFloat = 0) -> UIBezierPath {
            /// Note that we dont subtract padding.bottom and padding.right.
            /// We create context with size, which includes padding. (IconModel.size)
            UIBezierPath(rounded: CGRect(x: padding.left + borderWidth / 2, y: padding.top + borderWidth / 2,
                                         width: size.width - borderWidth, height: size.height - borderWidth),
                         byRounding: .allCorners,
                         radius: size.width / 2,
                         smoothing: smoothing)
        }
    }

}
