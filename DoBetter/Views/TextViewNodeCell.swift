//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import ViewNodes
import UIKit

protocol ExtendedTextViewDelegate: UITextViewDelegate {
    func onKeyboardEvent(textView: TextViewNode, event: KeyboardObserver.KeyboardEvent, keyboard: KeyboardNotificationPayload)
}

extension ExtendedTextViewDelegate {
    func onKeyboardEvent(textView: TextViewNode, event: KeyboardObserver.KeyboardEvent, keyboard: KeyboardNotificationPayload) {}
}

extension TextViewNode {
    struct Model: ViewModel, Equatable {
        let isEditable: Bool
        let isScrollEnabled: Bool
        let lineFragmentPadding: CGFloat
        var text: NSAttributedString
        let placeholder: NSAttributedString?
        let isKeyboardObserverNeeded: Bool
        let textContainerInset: UIEdgeInsets
        let padding: UIEdgeInsets
        let typingAttributes: [NSAttributedString.Key : Any]?

        weak var extendedDelegate: ExtendedTextViewDelegate?

        init(text: NSAttributedString, placeholder: NSAttributedString? = nil, isEditable: Bool = false, padding: UIEdgeInsets,
             isScrollEnabled: Bool = false, lineFragmentPadding: CGFloat = 5, isKeyboardObserverNeeded: Bool = false,
             typingAttributes: [NSAttributedString.Key : Any]? = nil, textContainerInset: UIEdgeInsets = .top(8) + .bottom(8),
             extendedDelegate: ExtendedTextViewDelegate? = nil) {
            self.text = text
            self.placeholder = placeholder
            self.isEditable = isEditable
            self.padding = padding
            self.isScrollEnabled = isScrollEnabled
            self.lineFragmentPadding = lineFragmentPadding
            self.isKeyboardObserverNeeded = isKeyboardObserverNeeded
            self.textContainerInset = textContainerInset
            self.typingAttributes = typingAttributes
            self.extendedDelegate = extendedDelegate
        }

        func setup(view: TextViewNode) {
            view.text(text)
                    .placeholder(placeholder)
                    .isEditable(isEditable)
                    .isScrollEnabled(isScrollEnabled)
                    .lineFragmentPadding(lineFragmentPadding)
                    .delegate(extendedDelegate)
                    .textContainerInset(textContainerInset)
                    .padding(padding)

            typingAttributes.let { view.typingAttributes($0) }
        }

        func updateModel(with view: TextViewNode) -> Self {
            .init(text: view.attributedText,
                  placeholder: placeholder,
                  isEditable: view.wrapped.isEditable,
                  padding: padding,
                  isScrollEnabled: view.wrapped.isScrollEnabled,
                  lineFragmentPadding: lineFragmentPadding,
                  isKeyboardObserverNeeded: isKeyboardObserverNeeded,
                  typingAttributes: view.wrapped.typingAttributes,
                  textContainerInset: textContainerInset,
                  extendedDelegate: extendedDelegate)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.isEditable == rhs.isEditable &&
                lhs.isScrollEnabled == rhs.isScrollEnabled &&
                lhs.lineFragmentPadding == rhs.lineFragmentPadding &&
                lhs.text == rhs.text &&
                lhs.placeholder == rhs.placeholder &&
                lhs.isKeyboardObserverNeeded == rhs.isKeyboardObserverNeeded &&
                lhs.textContainerInset == rhs.textContainerInset &&
                lhs.padding == rhs.padding
        }
    }
}

extension TextViewNode {
    class Cell: ViewNodeCellByView<TextViewNode> {
        typealias Model = CellViewModelByView<TextViewNode.Model, Cell>
    }
}
