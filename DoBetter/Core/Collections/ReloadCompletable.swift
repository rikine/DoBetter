//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit

protocol ReloadCompletable: AnyObject { func reloadData() }

extension ReloadCompletable {
    func run(transaction closure: (() -> Void)?, completion: (() -> Void)?) {
        guard let closure = closure else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        closure()
        CATransaction.commit()
    }

    func run(transaction closure: (() -> Void)?, completion: ((Self) -> Void)?) {
        run(transaction: closure) { [weak self] in
            guard let self = self else { return }
            completion?(self)
        }
    }

    func reloadData(completion closure: ((Self) -> Void)?) {
        run(transaction: { [weak self] in self?.reloadData() }, completion: closure)
    }
}

extension UITableView: ReloadCompletable {}

extension UICollectionView: ReloadCompletable {}
