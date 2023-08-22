//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation

/// Используйте для передачи нужных данных через модельку.
///
/// Например такой сценарий:
/// У вас 10 ордеров на экране, по нажатию на них надо открывать нужную деталку.
/// чтобы понять на какой ордер был нажат, можно передать его идентификатор через поле в модельке ячейки,
/// подписав его под протокол CellModelPayload
public protocol CellModelPayload: AnyEquatable {}

/// for empty value in skeletons
public struct CellModelEmptyPayload: CellModelPayload, Equatable {
    public init() {}
}

public protocol AnyPayloadableCellModel {
    var payload: CellModelPayload? { get set }
}

public protocol PayloadableCellModel: AnyPayloadableCellModel, Updatable { }

public extension PayloadableCellModel {
    func payload(_ newValue: CellModelPayload?) -> Self {
        updated(\.payload, with: newValue)
    }
}

public protocol SelectableCellModelPayload: CellModelPayload {
    var isSelectable: Bool { get }
}
