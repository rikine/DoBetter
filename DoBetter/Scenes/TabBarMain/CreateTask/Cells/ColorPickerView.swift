//
// Created by Никита Шестаков on 08.04.2023.
//

import Foundation
import UIKit
import ViewNodes

final class ColorPickerView: Image, Initializable {
    required override init() {
        super.init()
        size(.square(32)).border(color: .foreground4, width: 3).corner(radius: 8)
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let color: TaskModel.Color
        let isSelected: Bool

        func setup(view: ColorPickerView) {
            view.background(color: color.uiColor)
            if isSelected {
                view.icon(.init(glyph: Glyph(image: .init(systemName: "checkmark"))!))
            } else {
                view.icon(nil)
            }
        }
    }
}

extension ColorPickerView {
    class CollectionCell: ViewNodeCollectionCellByView<ColorPickerView> {
        typealias Model = CollectionCellViewModelByView<ColorPickerView.Model, CollectionCell>
    }

    typealias CollectionFlow = FlowCollectionCellModel<CollectionCell.Model>
}
