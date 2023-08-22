//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit

extension UITableView {
    var registeredClasses: [String: Any] {
        value(forKey: "_cell" + "ClassDict") as? [String: Any] ?? [:]
    }

    func register(models: CellViewAnyModel.Type...) {
        register(models: models)
    }

    func register(models: [CellViewAnyModel.Type]) {
        models.forEach(register)
    }

    func register(model: CellViewAnyModel.Type) {
        register(model.cellAnyType, forCellReuseIdentifier: model.cellStaticIdentifier)
    }
}
