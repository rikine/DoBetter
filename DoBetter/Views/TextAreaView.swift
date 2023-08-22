//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import ViewNodes
import UIKit

/// https://www.figma.com/file/44eGp3pYzBlYpYGeTRvrNt/Mobile-UI-Kit?node-id=29210%3A441113&t=IEFwSvkkyMYgur1z-4
/// Есть проблема с плэйсхолдером - если он больше одной строки, то отображается не полностью
final class TextAreaView: VStack, Initializable {
    private(set) var label: Text!
    private(set) var info: Text!
    private(set) var counter: Text!
    private(set) var textView: TextViewNode!

    var beginEditing: ((TextAreaView) -> Void)?
    var endEditing: ((TextAreaView) -> Void)?
    var textDidChange: ((TextAreaView) -> Void)?

    required override init() {
        super.init()
        config(backgroundColor: .clear)
        padding(.horizontal(16) + .vertical(12))
        spacing(4)
        content {
            label = Text()
            textView = TextViewNode().corner(radius: 8).background(color: .content2)

            func addObserver(for event: NSNotification.Name, selector: Selector) {
                NotificationCenter.default.addObserver(
                    self,
                    selector: selector,
                    name: event,
                    object: textView.wrapped)
            }

            addObserver(for: UITextView.textDidChangeNotification, selector: #selector(textViewDidChange))
            addObserver(for: UITextView.textDidBeginEditingNotification, selector: #selector(textViewDidBeginEditing))
            addObserver(for: UITextView.textDidEndEditingNotification, selector: #selector(textViewDidEndEditing))

            HStack()
                    .width(.fill)
                    .content {
                        info = Text().width(.fill).lines(0)
                        counter = Text()
                    }
        }
    }

    @objc private func textViewDidChange() {
        textDidChange?(self)
    }

    @objc private func textViewDidBeginEditing() {
        UIView.animate(withDuration: Animation.Duration.default) {
            self.textView.background(color: .foreground4)
        }
        beginEditing?(self)
    }

    @objc private func textViewDidEndEditing() {
        UIView.animate(withDuration: Animation.Duration.default) {
            self.textView.background(color: .content2)
        }
        endEditing?(self)
    }

    override func nodeLayoutSubviews() {
        super.nodeLayoutSubviews()

        guard let textViewMaxHeight = textView.maxSizeValue?.height, /// если есть максимальное значение высоты
              let contentHeight = textView.contentSizeThatFits(bounds.size)?.height else { return }
        /// то регулируем скролл у текст вью
        textView.isScrollEnabled(contentHeight >= textViewMaxHeight)
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, PayloadableCellModel, UpdatableWithoutReloadingRow {
        let label: NSAttributedString?
        let info: NSAttributedString?
        let counter: NSAttributedString?
        let textViewModel: TextViewNode.Model
        let maxHeight: CGFloat?
        let height: CGFloat? /// постоянная высота
        var payload: CellModelPayload?

        init(label: NSAttributedString? = nil, info: NSAttributedString? = nil, counter: NSAttributedString? = nil,
             textViewModel: TextViewNode.Model, height: CGFloat? = nil, maxHeight: CGFloat? = nil) {
            self.label = label
            self.info = info
            self.counter = counter
            self.textViewModel = textViewModel
            self.maxHeight = maxHeight
            self.height = height
        }

        func setup(view: TextAreaView) {
            view.label.textOrHidden(label)
            view.info.textOrHidden(info)
            view.counter.textOrHidden(counter)
            textViewModel.setup(view: view.textView)
            maxHeight.let { view.textView.maxHeight($0) }
            height.let { view.textView.height($0) }
        }

        static func ==(lhs: Model, rhs: Model) -> Bool {
            lhs.label == rhs.label &&
                lhs.info == rhs.info &&
                lhs.counter == rhs.counter &&
                lhs.textViewModel == rhs.textViewModel &&
                lhs.maxHeight == rhs.maxHeight &&
                lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }

        /// Если модель в таблице и ее можно редактировать, то иногда нужно получать обновленную модель, чтобы при обновлении таблицы она не стала прежней
        func updatedModel(with view: TextAreaView) -> Self {
            .init(label: view.label.wrapped.attributedText,
                  info: view.info.wrapped.attributedText,
                  counter: view.counter.wrapped.attributedText,
                  textViewModel: textViewModel.updateModel(with: view.textView),
                  height: height, maxHeight: maxHeight)
        }
    }
}

extension TextAreaView {
    class Cell: ViewNodeCellByView<TextAreaView>, ResponderCell {
        typealias Model = CellViewModelByView<TextAreaView.Model, Cell>

        var isEditingAllowed: Bool { mainView.textView.wrapped.isEditable }

        func makeCellFirstResponder() {
            mainView.textView.keyboardFocus(true)
        }
    }
}
