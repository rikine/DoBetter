//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit

extension UITableView {

    func dequeueReusableCell(withModel model: CellViewAnyModel, for indexPath: IndexPath) -> UITableViewCell {
        let identifier = model.identifier
        let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        /// Add empty tableViewFooter to remove last cell separator doesn't work in iOS15+
        if indexPath == lastRow {
            cell.hideDefaultSeparator()
        }

        model.setupAny(cell: cell)
        return cell
    }

    func dequeueReusableCell(withModel model: CellViewAnyModel) -> UITableViewCell? {
        let identifier = model.identifier
        if let cell = self.dequeueReusableCell(withIdentifier: identifier) {
            model.setupAny(cell: cell)
            return cell
        }
        return nil
    }

    func setup(delegate: UITableViewDelegate & UITableViewDataSource,
               backgroundColor: UIColor? = .background2,
               separatorColor: UIColor? = .background) {
        self.delegate = delegate
        self.dataSource = delegate
        self.tableFooterView?.backgroundColor = .clear
        self.tableFooterView = UIView()
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        self.backgroundView?.backgroundColor = .clear
        self.separatorColor = separatorColor
    }
}

extension UITableViewCell {
    func hideDefaultSeparator() {
        separatorInset = UIEdgeInsets(top: 0,
                                      left: .greatestFiniteMagnitude,
                                      bottom: 0,
                                      right: -.greatestFiniteMagnitude)
    }
}
