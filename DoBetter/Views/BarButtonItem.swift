//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    static func makeCustomItem(iconModel: IconModel, action: @escaping VoidClosure) -> BarButtonItem {
        .init(iconModel: iconModel).action(action)
    }
}

class BarButtonItem: UIBarButtonItem {
    private var customAction: VoidClosure?

    convenience init(title: String? = nil, style: UIBarButtonItem.Style = .plain, iconModel: IconModel) {
        self.init(title: title, style: style, target: nil, action: #selector(onAction))
        target = self
        image = iconModel.glyph.image
    }

    @discardableResult
    func action(_ action: @escaping VoidClosure) -> Self {
        customAction = action
        return self
    }

    @objc func onAction() {
        customAction?()
    }
}