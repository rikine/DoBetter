//
// Created by Никита Шестаков on 10.04.2023.
//

import Foundation
import ViewNodes

class CheckboxView: VStack, Initializable {
    private(set) var text: Text!
    private(set) var info: Text!
    private(set) var rightButton: Image!

    required override init() {
        super.init()

        spacing(8)
        config(backgroundColor: .clear)
        content {
            HStack().content {
                text = Text()
                View().width(.fill)
                rightButton = Image().size(24).corner(radius: 8).border(color: .foreground4)
            }

            info = Text()
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, PayloadableCellModel {
        let info: AttrString?
        let text: AttrString?
        let isSelected: Bool?
        var payload: CellModelPayload?

        init(text: AttrString? = nil, info: AttrString? = nil, isSelected: Bool?) {
            self.text = text
            self.info = info
            self.isSelected = isSelected
        }

        func setup(view: CheckboxView) {
            view.text.textOrHidden(text?.apply(.line.multiline.foreground))
            view.info.textOrHidden(info?.apply(.label.multiline.secondary))

            let icon: IconModel
            switch isSelected {
            case true: icon = .Task.check
            case false: icon = .Task.remove
            default: icon = .Task.emptyCircle
            }

            view.rightButton.icon(icon)
        }

        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.text == rhs.text && lhs.isSelected == rhs.isSelected
                && lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }
    }
}

extension CheckboxView {
    class Cell: ViewNodeCellByView<CheckboxView> {
        typealias Model = CellViewModelByView<CheckboxView.Model, Cell>
    }
}
