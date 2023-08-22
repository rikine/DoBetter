//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit
import DifferenceKit

/// Отвечает за обновление таблицы или коллекции через диффер
protocol DifferUpdatable: AnyObject {

    /// Тип для модели с новыми секциями. Тип секций должен соотвествовать типу секций у текущего вью
    associatedtype ViewModelToUpdate: DifferUpdatableViewModel where ViewModelToUpdate.SectionModel == SectionModel

    /// Тип вью, чьи секции и ячейки будут обновляться с помощью диффера
    associatedtype DifferUpdatableView: AnyDifferUpdatableView

    /// Тип секций у текущего вью
    associatedtype SectionModel: DifferSectionModelType

    /// Модели секций, которые будут обновляться с помощью диффера
    var sections: [SectionModel] { get set }

    /// Вью (напр., UITableView, UICollectionView), чьи секции и ячейки будут обновляться с помощью диффера
    var differUpdatableView: DifferUpdatableView? { get }

    /// Флаг, указывающий, происходит ли сейчас обновление через диффер (напр., вычисление changeset или релоад ячеек)
    var isDifferUpdateInProgress: Bool { get set }

    /// Последняя модель, с помощью которой требуется обновить вью через диффер
    /// Подразумевается использовать ее состояние для обновления секций,
    /// если она имеет инстанс после выполнения `updateViewWithDiffer(_:)`
    var pendingViewModel: ViewModelToUpdate? { get set }

    /// "Вход" в обновление через диффер. Сравнивает состояние `viewModel` с текущим состоянием
    /// и анимированно обновляет, если находит различия
    func updateViewWithDiffer(_ viewModel: ViewModelToUpdate)

    /// Корутиновая обертка для метода `updateViewWithDiffer(_:)`
    func updateViewWithDifferAsync(_ viewModel: ViewModelToUpdate) async
}

extension DifferUpdatable {

    /// Предпочтительный метод для обновления DifferUpdatableView через диффер. Использовать с `Task(priority: .high)`
    /// - Todo: после проверки бесперебойности работы в коллекции перенести таблицы на этот метод
    @MainActor func updateViewWithDifferAsync(_ viewModel: ViewModelToUpdate) async {
        guard let differUpdatableView else { return guardUnreachable("Provide view to reload with differ") }
        guard !isDifferUpdateInProgress else {
            pendingViewModel = viewModel
            return
        }
        isDifferUpdateInProgress = true

        let sectionsChangeset = await sections.sectionsChangeset(forNew: viewModel.sections)
        updateSections(sectionsChangeset: sectionsChangeset, viewModel: viewModel)

        differUpdatableView.updateWithoutReloading(sections: sections, sectionsChangeset: sectionsChangeset)
        differUpdatableView.finishUpdateWithoutReload()
        isDifferUpdateInProgress = false

        if let viewModel = pendingViewModel {
            pendingViewModel = nil
            await updateViewWithDifferAsync(viewModel)
        }
    }

    /// Если в changeset все ячейки обновились через updateAny(cell:), то просто устанавливаем значение sections.
    /// Если есть подходящие для релоада ячейки, то релоадим через DifferenceKit
    func updateSections(sectionsChangeset: SectionsChangeset<SectionModel>, viewModel: ViewModelToUpdate) {
        if sectionsChangeset.changesetToReload.isEmpty {
            sections = viewModel.sections
        } else if let differUpdatableView {
            differUpdatableView.reload(
                using: sectionsChangeset.changesetToReload,
                setData: { [weak self] data in
                    self?.sections = data.map(\.differentiableSection)
                }
            )
        }
    }

    /// Updates DifferUpdatableView with differ.
    /// Almost deprecated, `updateViewWithDifferAsync(_:) async` is preferred.
    func updateViewWithDiffer(_ viewModel: ViewModelToUpdate) {
        guard let differUpdatableView else { return guardUnreachable("Provide view to reload with differ") }
        guard !isDifferUpdateInProgress else {
            pendingViewModel = viewModel
            return
        }
        isDifferUpdateInProgress = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let sectionsChangeset = self.sections.sectionsChangeset(forNew: viewModel.sections)

            DispatchQueue.main.async {
                self.updateSections(sectionsChangeset: sectionsChangeset, viewModel: viewModel)

                differUpdatableView.updateWithoutReloading(sections: self.sections, sectionsChangeset: sectionsChangeset)
                self.isDifferUpdateInProgress = false
                differUpdatableView.finishUpdateWithoutReload()

                if let viewModel = self.pendingViewModel {
                    self.pendingViewModel = nil
                    self.updateViewWithDiffer(viewModel)
                }
            }
        }
    }
}
