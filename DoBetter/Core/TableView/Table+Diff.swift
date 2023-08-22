//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit
import DifferenceKit

/// Структура, разделяющая изначальный changeset библиотеки DifferenceKit на два:
/// 1) changesetToReload - ячейки, подходящие для релоада
/// 2) elementsToUpdate - модельки, который НЕ нужно релоадить, достаточно обновить через updateAny(cell:)
/// Мотивация: не вызывать лишний раз релоад (как источник возможных багов для нашей анимации)
public struct SectionsChangeset<Section: SectionDifferentiable> {
    let changesetToReload: StagedChangeset<[DiffArraySection<Section>]>
    let elementsToUpdate: [DifferentiableCellModelWrapper]
}

@globalActor public actor DifferActor {
    static public let shared: DifferActor = DifferActor()
}

public extension Array where Element: SectionDifferentiable {

    /// Мост по вычислению changeset для асинк контекста
    /// Использует глобал актор, чтобы производить вычисления не на мейн треде
    @DifferActor
    func sectionsChangeset(forNew newSource: [Element]) async -> SectionsChangeset<Element> {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: sectionsChangeset(forNew: newSource))
        }
    }

    /// Берет changeset, который отдал DifferenceKit, и фильтрует на ячейки, которые:
    /// 1) обновятся через reload и 2) ячейки, которые обновятся через updateAny(cell:)
    func sectionsChangeset(forNew newSource: [Element]) -> SectionsChangeset<Element> {
        var elementsToUpdate: [DifferentiableCellModelWrapper] = []

        let changeset = StagedChangeset(source: map(\.arraySection), target: newSource.map(\.arraySection))
                .compactMap { change -> Changeset<[DiffArraySection<Element>]>? in
                    var modified = change
                    modified.elementUpdated = modified.elementUpdated.compactMap { path in
                        guard self[path.section].cells[path.element] is AnyUpdatableWithoutReloadingRow else {
                            return path
                        }
                        elementsToUpdate.append(self[path.section].arraySection.elements[path.element])
                        return nil
                    }
                    if modified.hasChanges { return modified }
                    return nil
                }
        return .init(changesetToReload: StagedChangeset(changeset), elementsToUpdate: elementsToUpdate)
    }
}

public extension ArraySection where Model: SectionDifferentiable & Updatable, Element == DifferentiableCellModelWrapper {

    var differentiableSection: Model {
        model.cells(elements.map(\.wrapped))
    }
}
