//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

protocol TablePresentationLogic: PresentationLogic {
    var sections: [Table.SectionViewModel] { get }
    func firstIndexPath<T: CellViewModel>(of type: T.Type) -> IndexPath?
    func firstModel<T: CellViewModel>(of type: T.Type) -> T?
}

protocol TablePresenting: Presenting, TablePresentationLogic {}

extension TablePresenting {
    var tableViewController: TableDisplayLogic? {
        assertionCast(viewController, to: TableDisplayLogic.self)
    }

    func firstIndexPath<T: CellViewModel>(of type: T.Type) -> IndexPath? {
        sections.firstIndexPath(of: type)
    }

    func firstModel<T: CellViewModel>(of type: T.Type) -> T? {
        guard let indexPath = firstIndexPath(of: type) else { return nil }
        return sections[indexPath] as? T
    }
}
