//
// Created by Maxime Tenth on 10/31/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience public init(roundingSize: CGSize,
                            smoothing: CGFloat? = 0.777) {
        self.init(rounded: roundingSize.rect, radius: roundingSize.width / 2, smoothing: smoothing)
    }

    convenience public init(rounded rect: CGRect,
                            byRounding corners: UIRectCorner = .allCorners,
                            radius: CGFloat,
                            smoothing: CGFloat? = nil) {

        if let smoothing = smoothing {
            self.init()
            if corners.contains(.topLeft) {
                move(to: CGPoint(x: 0,
                                 y: radius))
                addCurve(to: CGPoint(x: radius,
                                     y: 0),
                         controlPoint1: CGPoint(x: 0, y: radius - radius * smoothing),
                         controlPoint2: CGPoint(x: radius - radius * smoothing, y: 0))
            } else {
                move(to: CGPoint(x: 0, y: 0))
            }

            if corners.contains(.topRight) {
                addLine(to: CGPoint(x: rect.width - radius,
                                    y: 0))
                addCurve(to: CGPoint(x: rect.width,
                                     y: radius),
                         controlPoint1: CGPoint(x: rect.width - radius + radius * smoothing, y: 0),
                         controlPoint2: CGPoint(x: rect.width, y: radius - radius * smoothing))
            } else {
                addLine(to: CGPoint(x: rect.width, y: 0))
            }

            if corners.contains(.bottomRight) {
                addLine(to: CGPoint(x: rect.width,
                                    y: rect.height - radius))
                addCurve(to: CGPoint(x: rect.width - radius,
                                     y: rect.height),
                         controlPoint1: CGPoint(x: rect.width, y: rect.height - radius + radius * smoothing),
                         controlPoint2: CGPoint(x: rect.width - radius + radius * smoothing, y: rect.height))
            } else {
                addLine(to: CGPoint(x: rect.width, y: rect.height))
            }

            if corners.contains(.bottomLeft) {
                addLine(to: CGPoint(x: radius, y: rect.height))
                addCurve(to: CGPoint(x: 0, y: rect.height - radius),
                         controlPoint1: CGPoint(x: radius - radius * smoothing, y: rect.height),
                         controlPoint2: CGPoint(x: 0, y: rect.height - radius + radius * smoothing))
            } else {
                addLine(to: CGPoint(x: 0, y: rect.height))
            }
            close()
            apply(CGAffineTransform(translationX: rect.origin.x, y: rect.origin.y))
        } else {
            self.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        }
    }
}
