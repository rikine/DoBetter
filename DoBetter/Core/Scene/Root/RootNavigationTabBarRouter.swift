//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation
import UIKit

protocol RootNavigationTabBarRoutingLogic {
}

protocol RootNavigationTabBarDataPassing {
    var dataStore: RootNavigationTabBarDataStore? { get }
}

final class RootNavigationTabBarRouter: RootNavigationTabBarRoutingLogic, RootNavigationTabBarDataPassing {
    weak var viewController: RootNavigationTabBarViewController?
    var dataStore: RootNavigationTabBarDataStore?
}
