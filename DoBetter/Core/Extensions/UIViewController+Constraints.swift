//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

public extension UIViewController {
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        view.safeAreaLayoutGuide.topAnchor
    }

    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        view.safeAreaLayoutGuide.bottomAnchor
    }

    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        view.safeAreaLayoutGuide.leftAnchor
    }

    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        view.safeAreaLayoutGuide.rightAnchor
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.delaysTouchesBegan = true
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(false)
    }
}
