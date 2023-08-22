//
// Created by Никита Шестаков on 22.03.2023.
//

import Foundation
import UIKit

extension UICollectionView {

    /// Рандомный нейминг для бэкграунда, потому что эпплу так хочется
    static let elementKindSectionBackground = "elementKindSectionBackground"

    func register(models: CellViewAnyModel.Type...) {
        register(models: models)
    }

    func register(models: [CellViewAnyModel.Type]) {
        models.forEach(register)
    }

    private func register(model: CellViewAnyModel.Type) {
        register(model.cellAnyType, forCellWithReuseIdentifier: model.cellStaticIdentifier)
    }

    func register(headers: ViewAnyModel.Type...) {
        register(headers: headers)
    }

    func register(headers: [ViewAnyModel.Type]) {
        headers.forEach(register(header:))
    }

    private func register(header: ViewAnyModel.Type) {
        register(supplementaryView: header, ofKind: UICollectionView.elementKindSectionHeader)
    }

    func register(supplementaryView: ViewAnyModel.Type, ofKind: String) {
        register(supplementaryView.viewAnyType,
                 forSupplementaryViewOfKind: ofKind,
                 withReuseIdentifier: supplementaryView.viewStaticIdentifier)
    }

    // Wait until reloadData() completed
    func awaitReloadData() {
        performBatchUpdates(nil, completion: nil) // ¯\_(ツ)_/¯
    }

    func dequeueReusableCell(withModel model: CellViewAnyModel, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
        model.setupAny(cell: cell)
        return cell
    }
}

extension UICollectionReusableView {
    /// Пустая модель для регистрации supplementaryItem во избежание выброса эксепшна во время dequeueReusableSupplementaryView
    struct Model: ViewModel {
        func setup(view: UICollectionReusableView) {}
    }
}

extension UICollectionViewLayout {
    func register<T: UICollectionReusableView>(decoration: T.Type) {
        register(decoration, forDecorationViewOfKind: reflectingType(of: decoration))
    }
}

@inline(__always)
func reflectingType<T>(of value: T) -> String {
    String(reflecting: type(of: value))
}

/// Creates a string representing the given value.
@inline(__always)
func describingType<T>(of value: T) -> String {
    String(describing: type(of: value))
}
