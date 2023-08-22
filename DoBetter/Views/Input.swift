//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation
import ViewNodes
import UIKit
import PhoneNumberKit

/// Протокол для таблицы, в которой множество инпутов
/// чтобы передать ввод на другую ячейку, которая подписана под этот протокол
protocol ResponderCell {
    /// Можно ли сделать ячейку FirstResponder
    var isEditingAllowed: Bool { get }

    func makeCellFirstResponder()
}


class Input: VStack, UITextFieldDelegate {
    var label: Text!
    var textField: UITextField!
    var textFieldWrapper: UIViewWrapper<UITextField>!
    var info: Text!
    var inputStack: HStack!
    var beginEditing: ((UITextField) -> Void)?
    var endEditing: ((UITextField) -> Void)?
    var onReturn: ((UITextField) -> Void)?
    var didChange: ((UITextField) -> Void)?
    var onCanceledChangeCharacters: ((UITextField) -> Void)?

    /// Fires on every text change, passing updated text value
    var onTextEdit: ((String) -> Void)?

    /// Fires when keyboard shows / hides
    var onKeyboardEvent: ((CGFloat) -> Void)?

    var shouldChangeCharacters: ((UITextField, NSRange, String) -> Bool)?
    var maxLength: Int?

    var leftIcon: Image!
    var rightIcon: Image!

    private var shouldHighlightOnFocus = false

    override init() {
        super.init()
        config(backgroundColor: .background2)
        content {
            VStack()
                    .spacing(4)
                    .content {
                        label = Text()

                        inputStack = HStack()
                                .spacing(8)
                                .alignment(.center)
                                .padding(.horizontal(12))
                                .corner(radius: 8)
                                .config(backgroundColor: .content2)
                                .height(44)
                                .line(edge: .bottom, color: .accent)

                        info = Text()
                    }
        }
    }

    private func makeInputStackContent(_ isPhone: Bool) {
        leftIcon = Image()

        if isPhone {
            textFieldWrapper = UIViewWrapper(PhoneNumberTextField(frame: .zero))
                    .width(.fill)
                    .height(20)
        } else {
            textFieldWrapper = UIViewWrapper(UITextField(frame: .zero))
                    .width(.fill)
                    .height(20)
        }
        textField = textFieldWrapper.wrapped
        textField.delegate = self
        if let textField = textField as? PhoneNumberTextField {
            textField.withFlag = true
            textField.withExamplePlaceholder = true
        }
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        rightIcon = Image()
    }

    // UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if shouldHighlightOnFocus {
            highlightOnFocusIn()
        }
        beginEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if shouldHighlightOnFocus {
            unHighlightOnFocusOut()
        }
        endEditing?(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?(textField)
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        didChange?(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as? NSString) ?? NSString()
        let updatedText = currentText.replacingCharacters(in: range, with: string)

        let updatedTextCount = updatedText.count

        // Apply formatter.
        let shouldChangeChars = (shouldChangeCharacters?(textField, range, string) ?? true)
        // Check if length surpass max
        let updatedTextFitsLimit = maxLength.let { updatedTextCount <= $0 } ?? true

        if shouldChangeChars && updatedTextFitsLimit {
            textEdited(updatedText)
            return true
            /// In this case changing textField.text in explicit manner.
            /// Can happen when pasting a text that surpass the limit
        } else if shouldChangeChars && !updatedTextFitsLimit, let maxLength = maxLength {
            let diff = updatedTextCount - maxLength
            let replacementText = String(string.prefix(string.count - diff))
            guard let updatedText = (textField.text as? NSString)?.replacingCharacters(in: range, with: replacementText)
            else { return false }
            textField.text = updatedText
            textEdited(updatedText)
            /// Moving the caret to the end of the string in the textfield. (Without .main.asyncAfter doesnt work)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak textField] in
                guard let textField = textField else { return }
                let newPosition = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return false
        } else {
            onCanceledChangeCharacters?(textField)
            return false
        }
    }

    func highlightOnFocusIn(with color: UIColor = .foreground4) {
        UIView.animate(withDuration: 0.2) {
            self.changeColorForMainStack(with: color)
        }
    }

    func unHighlightOnFocusOut(with color: UIColor = .content2) {
        UIView.animate(withDuration: 0.2) {
            self.changeColorForMainStack(with: color)
        }
    }

    private func changeColorForMainStack(with color: UIColor) {
        [inputStack, leftIcon, textFieldWrapper, rightIcon].forEach {
            $0.background(color: color)
        }
    }

    func clearText() {
        textField.text = nil
        onTextEdit?("") // text is changed, so we should call onTextEdit
    }

    /// Manually show or hide keyboard
    @discardableResult
    func keyboardFocus(_ newValue: Bool) -> Self {
        newValue ? textField.becomeFirstResponder() : textField.resignFirstResponder()
        return self
    }

    struct Model: ViewModel, Equatable {
        let inputID: AnyHashable
        let label: NSAttributedString?
        let placeholder: NSAttributedString?
        var value: NSAttributedString?
        var info: NSAttributedString?
        let typingAttributes: [NSAttributedString.Key: Any]
        let keyboardType: UIKeyboardType
        var isEditable: Bool
        let maxLength: Int?
        let disabledModel: IconModel.DisabledModel?
        let shouldHighlightOnFocus: Bool
        let rightIcon: IconModel?
        let leftIcon: IconModel?
        let isSecure: Bool
        let isPhone: Bool
        let formatter: ((UITextField, NSRange, String) -> Bool)?

        init(inputID: AnyHashable? = nil,
             label: NSAttributedString? = nil,
             placeholder: NSAttributedString? = nil,
             value: NSAttributedString? = nil,
             info: NSAttributedString? = nil,
             typingAttributes: [NSAttributedString.Key: Any] = [:],
             keyboardType: UIKeyboardType = .default,
             isEditable: Bool,
             maxLength: Int? = nil,
             disabledModel: IconModel.DisabledModel? = nil,
             shouldHighlightOnFocus: Bool = false,
             leftIcon: IconModel? = nil,
             rightIcon: IconModel? = nil,
             formatter: ((UITextField, NSRange, String) -> Bool)? = nil,
             isSecure: Bool = false,
             isPhone: Bool) {
            if let id = inputID {
                self.inputID = id
            } else {
                self.inputID = CommonInputID(rawValue: label?.string ?? "")
            }
            self.label = label
            self.info = info
            self.typingAttributes = typingAttributes
            self.keyboardType = keyboardType
            self.placeholder = placeholder
            self.value = value
            self.isEditable = isEditable
            self.maxLength = maxLength
            self.disabledModel = disabledModel
            self.shouldHighlightOnFocus = shouldHighlightOnFocus
            self.leftIcon = leftIcon
            self.rightIcon = rightIcon
            self.formatter = formatter
            self.isSecure = isSecure
            self.isPhone = isPhone
        }

        func setup(view: Input) {
            if view.inputStack.subnodes.isEmpty {
                view.inputStack.content {
                    view.makeInputStackContent(isPhone)
                }
            }

            view.label.textOrHidden(label)
            view.info.textOrHidden(info)

            view.textField.attributedPlaceholder = placeholder
            view.textField.attributedText = value
            view.textField.defaultTextAttributes = typingAttributes
            view.textField.keyboardType = isPhone ? .phonePad : keyboardType
            view.textField.isUserInteractionEnabled = isEditable
            
            if !CommandLine.arguments.contains("test") {
                view.textField.isSecureTextEntry = isSecure
            }
            view.textField.autocorrectionType = .no
            view.shouldHighlightOnFocus = shouldHighlightOnFocus

            view.rightIcon.disabledModel(disabledModel).iconOrHidden(rightIcon)
            view.leftIcon.disabledModel(disabledModel).iconOrHidden(leftIcon)

            view.maxLength = maxLength
            view.shouldChangeCharacters = formatter
        }

        static func ==(lhs: Input.Model, rhs: Input.Model) -> Bool {
            lhs.inputID == rhs.inputID && lhs.label?.string == rhs.label?.string
                && lhs.value?.string == rhs.value?.string && lhs.info?.string == rhs.info?.string
                && lhs.leftIcon == rhs.leftIcon && lhs.rightIcon == rhs.rightIcon && lhs.isSecure == rhs.isSecure
                && lhs.placeholder?.string == rhs.placeholder?.string && lhs.isEditable == rhs.isEditable
                && lhs.keyboardType == rhs.keyboardType && lhs.shouldHighlightOnFocus == rhs.shouldHighlightOnFocus
                && lhs.disabledModel == rhs.disabledModel && lhs.maxLength == rhs.maxLength && lhs.isPhone == rhs.isPhone
        }

        static let formatForNumbers: (UITextField, NSRange, String) -> Bool = { (_: UITextField, _: NSRange, string: String) in
            string.isNumber
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rightIcon.icon(nil).hidden(true)
        leftIcon.icon(nil).hidden(true)
        textField.isSecureTextEntry = false
        shouldChangeCharacters = nil
        maxLength = nil
        inputStack.content({})
    }

    func textEdited(_ string: String) {
        onTextEdit?(string)
    }
}

extension Collection {
    public func chunk(sizes: [Int]) -> [SubSequence] {
        var result: [SubSequence] = []
        var from = startIndex
        var to: Index
        while from != endIndex {
            to = index(from, offsetBy: sizes[optional: result.count] ?? sizes.last ?? 1, limitedBy: endIndex) ?? endIndex
            result.append(self[from..<to])
            from = to
        }
        return result
    }
}

extension String {
    var isNumber: Bool {
        compactMap({ Int(String($0)) }).count == count
    }

    func chunkFormatted(withChunkSizes chunkSizes: [Int] = [4],
                        withSeparator separator: Character = " ") -> String {
        filter { $0 != separator }.chunk(sizes: chunkSizes).map { String($0) }.joined(separator: String(separator))
    }
}

class InputCell: ViewNodeCell, ResponderCell {
    var input: Input!

    override func makeView() -> View {
        input = Input().padding(.vertical(12) + .horizontal(16))
        return input
    }

    var isEditingAllowed: Bool { input.textField.isUserInteractionEnabled }

    func makeCellFirstResponder() { input.keyboardFocus(true) }

    struct Model: CellViewModel, EquatableCellViewModel, Equatable, PayloadableCellModel, UpdatableWithoutReloadingRow {
        var inputModel: Input.Model
        var payload: CellModelPayload?

        var differenceIdentifier: String { inputModel.inputID.description }

        func setup(cell: InputCell) {
            inputModel.setup(view: cell.input)
        }

        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.inputModel == rhs.inputModel && lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }
    }
}

public struct CommonInputID: Identifier {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
