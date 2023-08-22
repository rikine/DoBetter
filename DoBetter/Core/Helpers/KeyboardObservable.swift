//
// Created by Никита Шестаков on 07.03.2023.
//

import Foundation
import UIKit
import ViewNodes

protocol KeyboardObservableTable: TableViewNodeController {
    var keyboardObserver: KeyboardObserver { get }
    func observeKeyboardAndOffsetRootView()
    func onKeyboard()
}

extension KeyboardObservableTable {
    func observeKeyboardAndOffsetRootView() {
        keyboardObserver.observeKeyboard { [weak view, weak bottomSnackBarBottom, weak self] payload, _ in
            guard let view = view as? View else { return }
            let trueKeyboardHeight = max(0, UIScreen.main.bounds.size.height - payload.frameEnd.origin.y)
            view.padding(.bottom(trueKeyboardHeight))
            bottomSnackBarBottom?.constant = -trueKeyboardHeight
            view.layoutSubviewsRecursively()
            self?.onKeyboard()
        }
    }

    func onKeyboard() {}
}
