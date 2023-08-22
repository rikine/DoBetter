//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit
import ViewNodes

extension CGSize {
    static func square(_ newValue: CGFloat) -> CGSize {
        CGSize(width: newValue, height: newValue)
    }
}

extension CGSize {
    public static func + (lhs: CGSize, rhs: UIEdgeInsets) -> CGSize {
        lhs + CGSize(width: rhs.horizontalSum, height: rhs.verticalSum)
    }

    public static func - (lhs: CGSize, rhs: UIEdgeInsets) -> CGSize {
        lhs - CGSize(width: rhs.horizontalSum, height: rhs.verticalSum)
    }
}
