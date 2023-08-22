//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import ViewNodes
import UIKit

class SpacerView: View, Initializable {
    required override init() {
        super.init()

        height(1)
        background(color: .clear)
    }

    struct Model: ViewModel, EquatableCellViewModel, Equatable {
        let color: UIColor

        init(color: UIColor = .foreground4) {
            self.color = color
        }

        func setup(view: SpacerView) {
            view.line(edge: .bottom, color: color)
        }
    }
}

extension SpacerView {
    class Cell: ViewNodeCellByView<SpacerView> {
        typealias Model = CellViewModelByView<SpacerView.Model, Cell>
    }
}
