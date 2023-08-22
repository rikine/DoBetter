//
// Created by Никита Шестаков on 22.03.2023.
//

import Foundation
import UIKit

struct CollectionCellViewModelByView<MainViewModel: ViewModel,
                                    WrapperCell: ViewNodeCollectionCellByView<MainViewModel.ViewType>>: CellViewModel {
    let mainViewModel: MainViewModel
    let backgroundColor: UIColor?
    let padding: UIEdgeInsets?

    init(_ mainViewModel: MainViewModel,
         backgroundColor: UIColor? = nil,
         padding: UIEdgeInsets? = nil) {
        self.mainViewModel = mainViewModel
        self.backgroundColor = backgroundColor
        self.padding = padding
    }

    /// Инит для красивого мапа: .map(Foo.CollectionCell.Model.init)
    init(_ mainViewModel: MainViewModel) {
        self.init(mainViewModel, backgroundColor: nil, padding: nil)
    }

    func setup(cell: WrapperCell) {
        mainViewModel.setupAny(view: cell.mainView)
        backgroundColor.let { cell.wrapperView.background(color: $0) }
        padding.let { cell.wrapperView.padding($0) }
    }
}

extension CollectionCellViewModelByView: Equatable, AnyEquatable where MainViewModel: Equatable {
    static func ==(lhs: CollectionCellViewModelByView, rhs: CollectionCellViewModelByView) -> Bool {
        if lhs.mainViewModel != rhs.mainViewModel { return false }
        if lhs.backgroundColor != rhs.backgroundColor { return false }
        if lhs.padding != rhs.padding { return false }
        return true
    }
}

extension CollectionCellViewModelByView: EquatableCellViewModel where MainViewModel: EquatableCellViewModel & Equatable {}
