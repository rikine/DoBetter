//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import UIKit

public protocol AnyUpdatableWithoutReloadingRow {
    /// - Если `true`, то обновляет ячейку с помощью метода `updateAny(cell:)`
    /// - Иначе reloadRows
    var canUpdateWithoutReloadingRow: Bool { get }

    /// Если все модели, которые нужно обновить будут иметь `isStaticHeight == true`,
    /// тогда begin/endUpdates не будет вызываться.
    ///
    /// P.S.: при вызове begin/endUpdates может происходит подергивание экрана при скроле
    var isStaticHeight: Bool { get }

    func updateAny(cell: UIView)
}

public extension AnyUpdatableWithoutReloadingRow {
    var canUpdateWithoutReloadingRow: Bool { true }
    var isStaticHeight: Bool { false }
}

/// Если подписать под данный протокол свою CellModel, то она будет иметь возможность обновлять контент ячейки
/// без reloadRows(at:) при работе с displayTableWithDiffer
///
/// PS. Этот протокол не будет работать если вы привязываете экшены к ячейкам через `cellForRow`!
/// Используйте `modify(cell:at:)` для этого
public protocol UpdatableWithoutReloadingRow: AnyUpdatableWithoutReloadingRow {
    associatedtype CellType: UIView
    /// По дефолту `setup(cell:)` или `setup(view:)`
    func update(cell: CellType)
}

public extension UpdatableWithoutReloadingRow {
    func updateAny(cell: UIView) {
        guard let cell = assertionCast(cell, to: CellType.self) else { return }
        update(cell: cell)
    }
}

public extension UpdatableWithoutReloadingRow where Self: CellViewModel {
    func update(cell: CellType) { setup(cell: cell) }
}

/// Для случая, когда используется с `CellViewModelByView`
public extension UpdatableWithoutReloadingRow where Self: ViewModel, CellType == ViewType {
    func update(cell: CellType) { setup(view: cell) }
}
