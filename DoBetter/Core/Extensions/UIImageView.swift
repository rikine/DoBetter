//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension UIImageView {

    private struct AssociatedKeys {
        static var key = "UIImageView.IconModel"
    }

    var iconModel: IconModel? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.key) as? IconModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func makeImage(from icon: IconModel?, animated: Bool = false) {
        iconModel = icon
        if animated {
            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) {
                self.image = icon?.makeImage()
            }
        } else {
            image = icon?.makeImage()
        }
    }
}
