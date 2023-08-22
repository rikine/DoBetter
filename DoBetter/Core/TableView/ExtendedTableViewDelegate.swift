//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

/// Use this protocol to extend default UITableViewDelegate protocol.
/// Add any methods for table view notifications.
public protocol ExtendedTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willUpdateWithoutReloading cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func onUpdateWithoutReload(_ tableView: UITableView)
    func onReload(_ tableView: UITableView)
    func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath)
}

public extension ExtendedTableViewDelegate {
    func tableView(_ tableView: UITableView, willUpdateWithoutReloading cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    func onUpdateWithoutReload(_ tableView: UITableView) {}
    func onReload(_ tableView: UITableView) {}
    func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
}

public extension UITableView {
    var extendedDelegate: ExtendedTableViewDelegate? {
        assertionCast(delegate, to: ExtendedTableViewDelegate.self)
    }
}
