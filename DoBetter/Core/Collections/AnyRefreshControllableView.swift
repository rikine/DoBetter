//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

import UIKit

/// Тип любого объекта, который может иметь и отображать рефреш контрол (спинер при пулл-ту-рефреше)
protocol AnyRefreshControllableView: AnyObject {
    var panGestureRecognizer: UIPanGestureRecognizer { get }
    var refreshControl: UIRefreshControl? { get set }
    func bringSubviewToFront(_ view: UIView)
}

extension AnyRefreshControllableView where Self: UIView {
    var panGestureRecognizerTranslation: CGPoint {
        get { panGestureRecognizer.translation(in: self) }
        set { panGestureRecognizer.setTranslation(newValue, in: self) }
    }
}

extension AnyRefreshControllableView {

    var isRefreshing: Bool {
        refreshControl?.isRefreshing == true
    }

    func setRefreshControl(style: RefreshControl.RefreshControlStyle, target: Any, action: Selector) {
        let refreshControl = RefreshControl(style: style)
        refreshControl.addTarget(target, action: action, for: .valueChanged)
        self.refreshControl = refreshControl
        bringSubviewToFront(refreshControl)
    }

    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}

extension UITableView: AnyRefreshControllableView {}
