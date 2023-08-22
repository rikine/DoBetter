//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation

extension TextViewNode.Model {
    static func textAreaModel(text: NSAttributedString, placeholder: NSAttributedString? = nil, isEditable: Bool = false,
                              isScrollEnabled: Bool = false, typingAttributes: [NSAttributedString.Key : Any]? = TextStyle.line.attributes,
                              isKeyboardObserverNeeded: Bool = false, extendedDelegate: ExtendedTextViewDelegate? = nil) -> TextViewNode.Model {
        .init(text: text,
              placeholder: placeholder,
              isEditable: isEditable,
              padding: .zero,
              isScrollEnabled: isScrollEnabled,
              isKeyboardObserverNeeded: isKeyboardObserverNeeded,
              typingAttributes: typingAttributes,
              textContainerInset: .all(12),
              extendedDelegate: extendedDelegate)
    }
}
