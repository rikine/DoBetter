//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import ViewNodes

class TextCell: VStack, Initializable {
    private(set) var label: Text!
    private(set) var text: Text!
    private(set) var info: Text!
    private(set) var rightButton: Text!
    private(set) var rightButtonV2: Text!

    required override init() {
        super.init()

        spacing(8)
        config(backgroundColor: .clear)
        content {
            HStack().content {
                label = Text()
                View().width(.fill)
                rightButton = Text()
            }

            HStack().content {
                text = Text()
                View().width(.fill)
                rightButtonV2 = Text()
            }

            info = Text()
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, PayloadableCellModel {
        let label: AttrString?
        let info: AttrString?
        let text: AttrString?
        let rightButton: AttrString?
        let rightButtonV2: AttrString?
        var payload: CellModelPayload?

        init(label: AttrString? = nil, text: AttrString? = nil, info: AttrString? = nil, rightButton: AttrString? = nil, rightButtonV2: AttrString? = nil) {
            self.label = label
            self.text = text
            self.info = info
            self.rightButton = rightButton
            self.rightButtonV2 = rightButtonV2
        }

        func setup(view: TextCell) {
            view.label.textOrHidden(label?.apply(.label.multiline.secondary))
            view.text.textOrHidden(text?.apply(.line.multiline.foreground))
            view.rightButton.textOrHidden(rightButton?.apply(.label.accent))
            view.rightButtonV2.textOrHidden(rightButtonV2?.apply(.label.accent))
            view.info.textOrHidden(info?.apply(.label.multiline.secondary))
        }

        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.label == rhs.label && lhs.text == rhs.text && lhs.rightButton == rhs.rightButton
                && lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }
    }
}

extension TextCell {
    class Cell: ViewNodeCellByView<TextCell> {
        typealias Model = CellViewModelByView<TextCell.Model, Cell>
    }
}
