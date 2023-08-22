//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit
import DifferenceKit

/// Любая вью, которая поддерживает обновление через диффер (ex: table view, collection view)
protocol AnyDifferUpdatableView: AnyObject {

    /// Массив индекспасов видимых элементов во вью.
    var indexPathsForVisibleItems: [IndexPath] { get }

    /// Анимирует несколько операций вставки, удаления, перезагрузки и перемещения в виде группы.
    func performBatchUpdates(_ updates: VoidClosure?, completion: ((Bool) -> Void)?)

    /// Применяет несколько анимированных обновлений поэтапно, используя `StagedChangeset`.
    func reload<C>(using stagedChangeset: StagedChangeset<C>, setData: (C) -> Void)

    /// Обновляет ячейки с помощью сетапа моделек, без релоада
    func updateDiffItemsWithModels(_ modelsToUpdate: [DifferModelToUpdate])

    /// Совершает любые действия после апдейта с помощью диффера
    func finishUpdateWithoutReload()
}

typealias DifferModelToUpdate = (itemModel: AnyUpdatableWithoutReloadingRow, indexPath: IndexPath)

extension AnyDifferUpdatableView {

    /// Обновляет DifferUpdatableView (ex: UITableView, UICollectionView) без релоада (через updateAny(cell:))
    func updateWithoutReloading<T: DifferSectionModelType>(sections: [T], sectionsChangeset: SectionsChangeset<T>) {
        let modelsToUpdate = fetchModelsToUpdate(sections: sections,
                                                 sectionsChangeset: sectionsChangeset)
        let isChangeHeightNeeded = modelsToUpdate.contains(where: \.itemModel.isStaticHeight, is: false)
        performUpdates(for: modelsToUpdate, isChangeHeightNeeded: isChangeHeightNeeded)
    }

    /// Совершает операции вставки, удаления, перезагрузки и перемещения в виде группы
    /// В зависимости от значения флага `isChangeHeightNeeded`, делает это моментально или анимированно
    ///
    /// Мотивация: Если нет необходимости изменять высоту видимых на экране ячеек
    /// (например, изменяется только текст), то нет смысла вызывать performBatchUpdates,
    /// который пытается пересчитать высоту ячеек и анимированно ее изменить
    func performUpdates(for modelsToUpdate: [DifferModelToUpdate], isChangeHeightNeeded: Bool) {
        isChangeHeightNeeded
            ? performBatchUpdates({ self.updateDiffItemsWithModels(modelsToUpdate) }, completion: nil)
            : updateDiffItemsWithModels(modelsToUpdate)
    }

    /// Возвращает из видимых на экране ячеек все, которые нужно обновить без релоада (через updateAny(cell:))
    func fetchModelsToUpdate<T: DifferSectionModelType>(
        sections: [T],
        sectionsChangeset: SectionsChangeset<T>
    ) -> [DifferModelToUpdate] {
        indexPathsForVisibleItems.compactMap { indexPath -> DifferModelToUpdate? in
            let currModel = sections[indexPath]
            let currModelDifferenceIdentifier = DifferentiableCellModelWrapper(wrapped: currModel).differenceIdentifier

            guard sectionsChangeset.elementsToUpdate.contains(where: \.differenceIdentifier, is: currModelDifferenceIdentifier),
                  let updateModel = currModel as? AnyUpdatableWithoutReloadingRow,
                  updateModel.canUpdateWithoutReloadingRow
            else { return nil }

            return (updateModel, indexPath)
        }
    }
}

extension UITableView: AnyDifferUpdatableView {

    public var indexPathsForVisibleItems: [IndexPath] {
        indexPathsForVisibleRows ?? []
    }

    public func reload<C>(using stagedChangeset: StagedChangeset<C>, setData: (C) -> Void) {
        reload(using: stagedChangeset, with: .fade, setData: setData)
    }

    func performUpdates(for modelsToUpdate: [DifferModelToUpdate],
                               isChangeHeightNeeded: Bool) {
        if isChangeHeightNeeded { beginUpdates() }
        updateDiffItemsWithModels(modelsToUpdate)
        if isChangeHeightNeeded { endUpdates() }
    }

    func updateDiffItemsWithModels(_ modelsToUpdate: [DifferModelToUpdate]) {
        modelsToUpdate.forEach { updateModel, indexPath in
            guard let cell = cellForRow(at: indexPath) else { return }
            extendedDelegate?.tableView(self, willUpdateWithoutReloading: cell, forRowAt: indexPath)
            extendedDelegate?.modify(cell: cell, forRowAt: indexPath)
            updateModel.updateAny(cell: cell)
        }
    }

    @objc open func finishUpdateWithoutReload() {
        extendedDelegate?.onUpdateWithoutReload(self)
    }
}
