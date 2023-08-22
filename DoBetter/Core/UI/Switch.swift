//
// Created by Никита Шестаков on 15.04.2023.
//

import Foundation
import ViewNodes
import UIKit

class Switch: UIViewWrapper<UISwitch> {

    var isOn: Bool { wrapped.isOn }

    override init() {
        super.init()
        wrapped.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    @objc private func switchChanged() {
        tapClosure?()
    }

    @discardableResult
    public func onTintColor(_ newValue: UIColor) -> Self {
        wrapped.onTintColor = newValue
        return self
    }

    @discardableResult
    public func thumbTintColor(_ newValue: UIColor) -> Self {
        wrapped.thumbTintColor = newValue
        return self
    }

    @discardableResult
    public func isOn(_ newValue: Bool, animated: Bool) -> Self {
        wrapped.setOn(newValue, animated: animated)
        return self
    }
}
