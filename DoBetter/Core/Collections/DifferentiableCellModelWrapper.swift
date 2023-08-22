//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import DifferenceKit

/// Мост, который связаывает наши CellViewAnyModel с библиотекой DifferenceKit благодаря конформу Differentiable
/// Оборачивает CellViewAnyModel, чтобы библиотека могла распознать в changeset наши секции с ячейками
public struct DifferentiableCellModelWrapper: Differentiable {

    public let wrapped: CellViewAnyModel

    public init(wrapped: CellViewAnyModel) {
        self.wrapped = wrapped
    }

    public func isContentEqual(to source: DifferentiableCellModelWrapper) -> Bool {
        // Если ячейки разные, то и контент разный
        guard type(of: self.wrapped) == type(of: source.wrapped) else { return false }

        // При условии что оба одинакового типа и кто-то из них не конформит протокол (т.е. ОБА)
        // Возвращаем `true` чтобы ячейка не обновлялась
        guard let lhs = assertionCast(wrapped, to: EquatableCellViewModel.self),
              let rhs = assertionCast(source.wrapped, to: EquatableCellViewModel.self) else {
            return true
        }

        // А потом уже сравниваем контент
        return lhs.isEqual(to: rhs)
    }

    public var differenceIdentifier: String {
        guard let model = assertionCast(wrapped, to: EquatableCellViewModel.self) else {
            return "__just__weird__line__as__identifier__"
        }
        return String(describing: type(of: wrapped)) + model.differenceIdentifier
    }
}
