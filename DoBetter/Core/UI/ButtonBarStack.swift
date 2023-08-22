//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import ViewNodes
import UIKit

class ButtonBarStack: View, Initializable {
    var title: Text!
    var buttonGroup: StackOf<RoundCornersButton>!
    var stackWrapper: VStack!

    var isTopButtonEnabled: Bool {
        topButton?.wrapped.isEnabled ?? false
    }

    var topButton: RoundCornersButton? {
        buttonGroup.subviewsOf.first
    }

    required override init() {
        super.init()
        makeView(.vertical)
    }

    init(_ axis: Axis) {
        super.init()
        makeView(axis)
    }

    private func makeView(_ axis: Axis) {
        width(.fill)
        config(backgroundColor: .clear)
        line(edge: .top, color: .foreground4, isHidden: true)
        content {
            stackWrapper = VStack()
                    .padding(.all(16))
                    .spacing(15)
                    .content {
                        title = Text()
                        buttonGroup = StackOf<RoundCornersButton>(axis: axis)
                                .spacing(16)
                                .template(view: RoundCornersButton().width(.fill))
                    }
        }
    }

    struct Model: Equatable, ViewModel, EquatableCellViewModel, UpdatableWithoutReloadingRow {
        let title: NSAttributedString?
        let hasSeparator: Bool
        let backgroundColor: UIColor
        let buttons: [RoundCornersButton.Model]

        init(title: NSAttributedString? = nil, backgroundColor: UIColor = .clear,
             hasSeparator: Bool = false, buttons: [RoundCornersButton.Model]) {
            self.title = title
            self.backgroundColor = backgroundColor
            self.hasSeparator = hasSeparator
            self.buttons = buttons
        }

        func setup(view: ButtonBarStack) {
            view.title.textOrHidden(title)
            view.buttonGroup.update(with: buttons)

            view.background(color: backgroundColor)
            view.lineHidden(!hasSeparator)
        }
    }

    class Cell: ViewNodeCellByView<ButtonBarStack> {
        typealias Model = CellViewModelByView<ButtonBarStack.Model, Cell>
    }
}

extension StackOf {
    func update<Model: ViewModel>(with models: [Model]) where V == Model.ViewType {
        update(with: models) { (view: V, model: Model) in
            model.setup(view: view)
        }
    }
}
