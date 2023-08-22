//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation

protocol RootNavigationTabBarPresentationLogic {
    func presentScreen(_ screen: RootNavigationTabBar.TabBarScreen.Response)
}

final class RootNavigationTabBarPresenter: RootNavigationTabBarPresentationLogic {

    weak var viewController: RootNavigationTabBarDisplayLogic?

    func presentScreen(_ response: RootNavigationTabBar.TabBarScreen.Response) {
        let tabIndex = response.identifier.tabIndex
        viewController?.setStartScreenIndex(.init(tabIndex: tabIndex))
    }
}
