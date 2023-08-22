//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import ViewNodes
import UIKit

/// About view:
/// Wrapper for KMPlaceholderTextView which is UITextView with placeholder support
final class TextViewNode: UIViewWrapper<KMPlaceholderTextView>, Initializable {

    /// Note if attributedText is set, then `wrapped.text` and `wrapped.attributedText.string` have same value.
    var text: String { wrapped.text }

    var attributedText: NSAttributedString { wrapped.attributedText }

    /// Indicates whether keyboard is currently on screen or not
    var isKeyboardFocused: Bool { wrapped.isFirstResponder }

    var panGestureRecognizer: UIPanGestureRecognizer { wrapped.panGestureRecognizer }

    override init() {
        super.init()
        wrapped.showsVerticalScrollIndicator = false
        wrapped.showsHorizontalScrollIndicator = false
        keyboardDismissMode(.interactive)
        textContainerInset(.top(8) + .bottom(24))
    }

    @discardableResult
    func text(_ newValue: NSAttributedString) -> Self {
        wrapped.attributedText = newValue
        return self
    }

    /// Setup placeholder. Do it once. It will be shown automatically when text or attributedText is empty.
    @discardableResult
    func placeholder(_ newValue: NSAttributedString?) -> Self {
        wrapped.placeholderLabel.attributedText = newValue
        return self
    }

    /// A text view delegate responds to editing-related messages from the text view.
    /// You can use the delegate to track changes to the text itself and to the current selection.
    @discardableResult
    func delegate(_ newValue: ExtendedTextViewDelegate?) -> Self {
        wrapped.delegate = newValue
        return self
    }

    /// The manner in which the keyboard is dismissed when a drag begins in the scroll view.
    @discardableResult
    func keyboardDismissMode(_ newValue: UIScrollView.KeyboardDismissMode) -> Self {
        wrapped.keyboardDismissMode = newValue
        return self
    }

    /// This dictionary contains the attribute keys (and corresponding values) to apply to newly typed text.
    /// When the text view’s selection changes, the contents of the dictionary are cleared automatically.
    @discardableResult
    func typingAttributes(_ newValue: [NSAttributedString.Key : Any]) -> Self {
        wrapped.typingAttributes = newValue
        return self
    }

    @discardableResult
    func typingAttributes(for textStyle: TextStyle) -> Self {
        typingAttributes(textStyle.attributes)
    }

    /// A Boolean value that indicates whether the text view is editable.
    /// The default value of this property is true.
    @discardableResult
    func isEditable(_ newValue: Bool) -> Self {
        wrapped.isEditable = newValue
        return self
    }

    @discardableResult
    func isScrollEnabled(_ newValue: Bool) -> Self {
        wrapped.isScrollEnabled = newValue
        return self
    }

    /// This property controls the ability of the user to select content and interact with URLs
    /// and text attachments. The default value is true.
    @discardableResult
    func isSelectable(_ newValue: Bool) -> Self {
        wrapped.isSelectable = newValue
        return self
    }

    /// This property provides text margins for text laid out in the text view.
    @discardableResult
    func textContainerInset(_ newValue: UIEdgeInsets) -> Self {
        wrapped.textContainerInset = newValue
        return self
    }

    @discardableResult
    func scrollIndicatorInsets(_ newValue: UIEdgeInsets) -> Self {
        wrapped.scrollIndicatorInsets = newValue
        return self
    }

    /// Use to change cursor color, default `.accent`
    @discardableResult
    func tintColor(_ newValue: UIColor) -> Self {
        wrapped.tintColor = newValue
        return self
    }

    /// The padding appears at the beginning and end of the line fragment rectangles. The layout manager
    /// uses this value to determine the layout width. The default value of this property is 5.0.
    @discardableResult
    func lineFragmentPadding(_ newValue: CGFloat) -> Self {
        wrapped.textContainer.lineFragmentPadding = newValue
        return self
    }

    /// You can use this property to specify the types of data (phone numbers, http links, and so on)
    /// that should be automatically converted to URLs in the text view. When tapped, the text view opens
    /// the application responsible for handling the URL type and passes it the URL. Note that data
    /// detection does not occur if the text view's isEditable property is set to true.
    @discardableResult
    func dataDetectorTypes(_ newValue: UIDataDetectorTypes) -> Self {
        wrapped.dataDetectorTypes = newValue
        return self
    }

    /// The default attributes specify blue text with a single underline and the pointing hand cursor.
    @discardableResult
    func linkTextAttributes(_ newValue: [NSAttributedString.Key : Any]) -> Self {
        wrapped.linkTextAttributes = newValue
        return self
    }

    /// Mode for scroll to a specific area of the content so that it is visible in the receiver.
    @discardableResult
    func scrollToVisibleMode(_ newValue: Scroll.RectToVisible.Mode) -> Self {
        wrapped.scrollToVisibleMode = newValue
        return self
    }

    /// Manually show or hide keyboard.
    /// Don't forget about cmd+K if you use simulator.
    ///
    /// Note:
    /// `textViewShouldBeginEditing` triggers before the text view becomes the first responder.
    /// `textViewDidBeginEditing` will trigger when the text view becomes the first responder
    /// `textViewShouldEndEditing` is called when the text view is asked to resign the first responder status.
    /// `textViewDidEndEditing` resigns text view first responder status.
    @discardableResult
    func keyboardFocus(_ newValue: Bool) -> Self {
        newValue ? wrapped.becomeFirstResponder() : wrapped.resignFirstResponder()
        return self
    }

    /// Open keyboard if hidden or hide if opened
    func toggleKeyboardFocus() {
        keyboardFocus(!isKeyboardFocused)
    }
}
