//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import DifferenceKit

public protocol EquatableCellViewModel: AnyEquatable {
    var differenceIdentifier: String { get }
}

public extension EquatableCellViewModel {
    var differenceIdentifier: String { String(reflecting: type(of: self)) }
}

/// Тип с секциями, пригодными для обновления через диффер
public protocol DifferUpdatableViewModel {
    associatedtype SectionModel: DifferSectionModelType
    var sections: [SectionModel] { get set }
}

/// Тип для конформа модели секции, используемой для обновления через диффер
public protocol DifferSectionModelType: SectionDifferentiable, IndexPathSubscript<CellViewAnyModel>, Updatable {}

/// Модель секции, которая может формировать changeset с помощью своих ячеек
public typealias SectionDifferentiable = AnyDifferentiableModel & CellModelsControllable & HeaderModelContainable

/// Тип массива элементов, которые мы отправляем в DifferenceKit для формирования changeset
public typealias DiffArraySection<Section: SectionDifferentiable> = ArraySection<Section, DifferentiableCellModelWrapper>

typealias CollectionViewModelToUpdate = DifferUpdatableViewModel & Initializable & EmptyPlaceholderContainable

/// Тип, который сожержит модель хедера
public protocol HeaderModelContainable {
    var header: ViewAnyModel? { get }
}

public protocol EmptyPlaceholderContainable {
    var emptyPlaceholder: ViewAnyModel? { get }
}

/// Тип, который управляет моделями ячеек
public protocol CellModelsControllable: Updatable {
    var cells: [CellViewAnyModel] { get set }
}

public extension Array where Element: CellModelsControllable {
    var allCellsAreEmpty: Bool {
        first { $0.cells.isEmpty == false } == nil
    }
}

public extension CellModelsControllable where Self: Updatable {

    @discardableResult
    func cells(_ newValue: [CellViewAnyModel]) -> Self {
        updated(\.cells, with: newValue)
    }
}

/// Тип любой модели, которая может быть использована для формирования changeset
/// Имеет дефолтное поведение, если содержит ячейки
public protocol AnyDifferentiableModel: Differentiable {
    var arraySection: ArraySection<Self, DifferentiableCellModelWrapper> { get }
}

public extension AnyDifferentiableModel where Self: CellModelsControllable {

    /// Массив элементов из секций и соотвествующих ячеек, обернутых во враппер, для формирования changeset
    var arraySection: ArraySection<Self, DifferentiableCellModelWrapper> {
        ArraySection(model: self, elements: cells.map(DifferentiableCellModelWrapper.init))
    }

    /* TODO: Если захотите делать перемещение/вставку/удаление секций,
    То надо что-то придумать для сравнивания контента секция
    Мб сравнить все элементы секцию или что-то подобное */
    func isContentEqual(to source: Self) -> Bool { true }
}
