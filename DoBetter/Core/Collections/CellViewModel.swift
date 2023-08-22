//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import UIKit

public protocol CellViewAnyModel {
    static var cellAnyType: UIView.Type { get }
    static var cellStaticIdentifier: String { get }
    var identifier: String { get }
    func setupAny(cell: UIView)
    var estimatedHeight: CGFloat? { get }
}

public extension CellViewAnyModel {
    var estimatedHeight: CGFloat? { nil }
}

public protocol CellViewModel: CellViewAnyModel {
    associatedtype CellType: UIView
    func setup(cell: CellType)
}

public extension CellViewModel {

    static var cellAnyType: UIView.Type { CellType.self }
    static var cellStaticIdentifier: String { String(reflectingWithoutBundleName: Self.cellAnyType) }

    var identifier: String { Self.cellStaticIdentifier }

    func setupAny(cell: UIView) {
        guard let cell = assertionCast(cell, to: CellType.self) else { return }
        setup(cell: cell)
    }
}
