//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

extension UIView {

    func setNeedsLayoutRecursively() {
        subviews.forEach {
            $0.setNeedsLayoutRecursively()
        }
        setNeedsLayout()
    }

    func layoutSubviewsRecursively() {
        layoutSubviews()
        subviews.forEach {
            $0.layoutSubviewsRecursively()
        }
    }

    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    func add(snackBar: SnackBar, safeAreaTopAnchor: NSLayoutYAxisAnchor? = nil) {
        let topConstraint: Constraint
        if let safeAreaTopAnchor = safeAreaTopAnchor {
            topConstraint = .equal(\.topAnchor, safeAreaTopAnchor)
        } else {
            topConstraint = .equal(\.topAnchor)
        }
        addSubview(snackBar, constraints: [
            .equal(\.leadingAnchor),
            topConstraint,
            .equal(\.trailingAnchor)
        ])
    }
}
