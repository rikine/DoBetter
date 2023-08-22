//
// Created by Никита Шестаков on 08.04.2023.
//

import Foundation
import ViewNodes

final class TaskSectionPickerView: View, Initializable, ResizableView {
    private(set) var text: Text!

    var cellSize: CGSize {
        (text.wrapped.attributedText?.boundingRect(with: .init(width: CGFLOAT_MAX, height: 32),
                                                   options: .usesLineFragmentOrigin,
                                                   context: nil).size ?? .zero) + .init(width: 16, height: 16)
    }

    required override init() {
        super.init()
        config(backgroundColor: .clear)
        corner(radius: 16)
        border(color: .foreground4, width: 3)
        padding(.all(8))
        content {
            text = Text()
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let section: SectionModel
        let isSelected: Bool

        func setup(view: TaskSectionPickerView) {
            view.text.text(section.localized.attrString.apply(.line.foreground))
            view.background(color: isSelected ? .content2 : .clear)
        }
    }
}

extension TaskSectionPickerView {
    class CollectionCell: ViewNodeCollectionCellByView<TaskSectionPickerView>, ResizableView {
        var cellSize: CGSize { mainView.cellSize }

        typealias Model = CollectionCellViewModelByView<TaskSectionPickerView.Model, CollectionCell>
    }

    typealias CollectionFlow = FlowCollectionCellModel<CollectionCell.Model>
}


