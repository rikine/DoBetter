//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit

public extension IndexPath {

    func isLastRowInSection(of tableView: UITableView) -> Bool {
        row == tableView.numberOfRows(inSection: section) - 1
    }

    func isLastRow(of tableView: UITableView) -> Bool {
        self == tableView.lastRow
    }

    func nextRow(from indexPath: IndexPath, of tableView: UITableView) -> IndexPath? {
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        return tableView.isValid(nextIndexPath) ? nextIndexPath : nil
    }

    func nextSection(from indexPath: IndexPath, of tableView: UITableView) -> IndexPath? {
        let nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
        return tableView.isValid(nextIndexPath) ? nextIndexPath : nil
    }

    func nextIndexPath(from indexPath: IndexPath, of tableView: UITableView) -> IndexPath? {
        nextRow(from: indexPath, of: tableView) ?? nextSection(from: indexPath, of: tableView)
    }
}

public extension UITableView {

    var lastSection: Int? {
        guard numberOfSections > 0 else { return nil }
        return numberOfSections - 1
    }

    func lastRow(inSection section: Int) -> IndexPath? {
        guard section < numberOfSections else { return nil }
        return IndexPath(row: numberOfRows(inSection: section) - 1, section: section)

    }

    var lastRow: IndexPath? {
        guard let lastSection = lastSection else { return nil }
        return lastRow(inSection: lastSection)
    }

    func numberOfRows() -> Int {
        numberOfRowsBeforeSection(numberOfSections)
    }

    func numberOfRowsBeforeSection(_ section: Int) -> Int {
        (0..<section).map(numberOfRows).reduce(0, +)
    }

    func numberOfRows(after indexPath: IndexPath) -> Int {
        numberOfRows() - numberOfRowsBeforeSection(indexPath.section) - indexPath.row - 1
    }

    func nextIndexPath(from indexPath: IndexPath) -> IndexPath? {
        indexPath.nextIndexPath(from: indexPath, of: self)
    }

    func isValid(_ indexPath: IndexPath) -> Bool {
        numberOfSections > indexPath.section && numberOfRows(inSection: indexPath.section) > indexPath.row
    }
}
