//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation

protocol RootNavigationTabBarBusinessLogic {
    func selectTabBarScreen(_ request: RootNavigationTabBar.TabBarScreen.Request)
}

protocol RootNavigationTabBarDataStore {
}

final class RootNavigationTabBarInteractor: NSObject, RootNavigationTabBarBusinessLogic, RootNavigationTabBarDataStore {

    var presenter: RootNavigationTabBarPresentationLogic?

    func selectTabBarScreen(_ request: RootNavigationTabBar.TabBarScreen.Request) {
        let screen = request.identifier ?? TabBarScreenOption.defaultScreenIdentifier
        presenter?.presentScreen(.init(identifier: screen))
    }
}
