//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import ViewNodes

extension Text {
    @discardableResult
    func text(_ newValue: AttrString?) -> Self {
        text(newValue.interpolated())
    }

    @discardableResult
    func textOrHidden(_ attrString: AttrString?) -> Self {
        textOrHidden(attrString.interpolated())
    }

    @discardableResult
    func clearText() -> Self {
        self.text(nil as NSAttributedString?)
    }
}
