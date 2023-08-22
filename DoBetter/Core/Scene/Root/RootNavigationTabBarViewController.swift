//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation
import UIKit

protocol RootNavigationTabBarDisplayLogic: AnyObject {
    func setStartScreenIndex(_ viewModel: RootNavigationTabBar.TabBarScreen.ViewModel)
}

final class RootNavigationTabBarViewController: UITabBarController,
                                                UITabBarControllerDelegate,
                                                RootNavigationTabBarDisplayLogic {

    var interactor: RootNavigationTabBarBusinessLogic?
    var router: (RootNavigationTabBarRoutingLogic & RootNavigationTabBarDataPassing)?

    var myFeedCoordinator: MyFeedCoordinator?
    var otherFeedCoordinator: OtherFeedCoordinator?

    private var _viewWasNeverAppeared = true

    var selectedTopViewController: UIViewController? {
        (selectedViewController as? UINavigationController)?.viewControllers.last
    }

    override func loadView() {
        super.loadView()
        _setupTabBar()
        /// https://stackoverflow.com/a/36826080/18963229
        /// If setup is in init(), it may work after(!) viewDidLoad.
        _setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        /// Set here or weird bugs can happen
        setViewControllers([setupMyFeed(), setupOtherFeed()], animated: false)

        if _viewWasNeverAppeared {
            _viewWasNeverAppeared = false
        }
        interactor?.selectTabBarScreen(.init())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.selectTabBarScreen(.init())
    }

    let separator = UIView()

    private func _setupTabBar() {
        tabBar.tintColor = .accent
        tabBar.unselectedItemTintColor = .foreground3

        separator.backgroundColor = .foreground4
        separator.isUserInteractionEnabled = false
        tabBar.addSubview(separator,
                          constraints:
                          .equal(\.topAnchor),
                          .equal(\.leftAnchor),
                          .equal(\.rightAnchor),
                          .equalToConstant(\.heightAnchor, 1))
    }

    private func setupMyFeed() -> UIViewController {
        let coordinator = MyFeedCoordinator(on: .initialize())
        coordinator.navigationController.tabBarItem = .init(title: Localization.TabBar.myFeed.localized,
                                                            image: IconModel.Task.home.glyph.image,
                                                            selectedImage: IconModel.Task.home.glyph.image)
        coordinator.navigationController.statusBarStyle = nil
        coordinator.start()
        myFeedCoordinator = coordinator
        return coordinator.navigationController
    }

    private func setupOtherFeed() -> UIViewController {
        let coordinator = OtherFeedCoordinator(on: .initialize())
        coordinator.navigationController.tabBarItem = .init(title: Localization.TabBar.feed.localized,
                                                            image: IconModel.Task.feed.glyph.image,
                                                            selectedImage: IconModel.Task.feed.glyph.image)
        coordinator.navigationController.statusBarStyle = nil
        coordinator.start()
        otherFeedCoordinator = coordinator
        return coordinator.navigationController
    }

    // MARK: - Setup

    private func _setup() {
        let interactor = RootNavigationTabBarInteractor()
        let presenter = RootNavigationTabBarPresenter()
        let router = RootNavigationTabBarRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataStore = interactor
    }

    // MARK: - Routing

    func displayPartition(_ partition: LocalAction) {}

    // MARK: - Display logic

    func setStartScreenIndex(_ viewModel: RootNavigationTabBar.TabBarScreen.ViewModel) {
        selectedIndex = viewModel.tabIndex
    }

    func dismiss() {
        viewControllers?.forEach { nvc in
            (nvc as? MainNavController)?.setViewControllers([], animated: false)

            if nvc.presentedViewController != nil {
                nvc.dismiss(animated: false)
            }
        }

        let navController1 = myFeedCoordinator?.navigationController
        let navController2 = otherFeedCoordinator?.navigationController
        dismissMany()
        myFeedCoordinator = nil
        otherFeedCoordinator = nil
        setViewControllers(nil, animated: false)
        navigationController?.viewControllers = []
        
        navController1?.observers.reap()
        navController2?.observers.reap()
    }
}
