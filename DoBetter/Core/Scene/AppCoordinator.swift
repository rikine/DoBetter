//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    static let shared = AppCoordinator()

    let window = MainUIWindow(frame: UIScreen.main.bounds)
    var navigationController: MainNavController
    private var viewControllersForShow = [UIViewController]()
    private let userDefaults = UserDefaults.standard

    private lazy var signInCoordinator = SignInCoordinator(on: navigationController)
    private lazy var pinCodeCoordinator = PinCodeCoordinator(on: navigationController)
    private lazy var rootCoordinator = RootCoordinator()

    private lazy var startsFrom: ScreenType? = CommandLine.arguments.compactMap {
        ScreenType.allCases.first(where: \.rawValue, is: $0)
    }.first

    override private init() {
        navigationController = MainNavController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.setupContentByTheme()
    }

    override func start() {
        _setup()
        showStartScreen()
    }

    func start(_ screen: ScreenType) {
        switch startsFrom ?? screen {
        case .mainTab: showMainTab()
        case .pinCode: showPinCode()
        case .signIn: showSignIn()
        }

        startsFrom = nil
    }

    func clear() {
        baseReCreateRootNavigationController()
        start()
    }

    private func _setup() {
        let splash = UIStoryboard(name: "LaunchScreen", bundle: nil)
                .instantiateViewController(withIdentifier: "LaunchScreen")
        navigationController.setViewControllers([splash], animated: false)
    }

    private func showStartScreen() {
        guard startsFrom == nil else {
            start(.signIn)
            return
        }
        
        if userDefaults.value(forKey: UserDefaultsKey.profileToken) == nil {
            showSignIn()
        } else if userDefaults.value(forKey: UserDefaultsKey.bioAuthEnabled) as? Bool == true {
            showPinCode()
        } else {
            showMainTab()
        }
    }

    private func showSignIn() {
        appendScreenAndShow(.signIn)
    }

    private func showPinCode() {
        appendScreenAndShow(.pinCode)
    }

    private func showMainTab() {
        appendScreenAndShow(.mainTab)
    }

    private func appendScreenAndShow(_ screens: [ScreenType]) {
        if screens.contains(.mainTab) {
            rootCoordinator.navigationController.modalTransitionStyle = .crossDissolve
            rootCoordinator.navigationController.modalPresentationStyle = .overCurrentContext
            
            navigationController.present(rootCoordinator.navigationController, animated: true)
            return
        }
        
        screens.forEach { type in
            switch type {
            case .mainTab: unreachable()
            case .signIn: viewControllersForShow.append(signInCoordinator.root.viewController)
            case .pinCode: viewControllersForShow.append(pinCodeCoordinator.root.viewController)
            }
        }
        showScreen()
    }

    private func appendScreenAndShow(_ screens: ScreenType...) {
        appendScreenAndShow(screens)
    }

    private func showScreen() {
        viewControllersForShow.first?.hideBackTitle()
        navigationController.setViewControllers(viewControllersForShow, animated: true)
        viewControllersForShow.removeAll()
        navigationController.dismissMany()
    }

    enum ScreenType: String, CaseIterable {
        case signIn, mainTab, pinCode
    }

    private func baseReCreateRootNavigationController() {
        navigationController.dismiss(animated: true)

        navigationController = MainNavController()
        navigationController.setNeedsStatusBarAppearanceUpdate()
        window.rootViewController = navigationController
        signInCoordinator = SignInCoordinator(on: navigationController)
        pinCodeCoordinator = PinCodeCoordinator(on: navigationController)
        rootCoordinator = RootCoordinator()
        window.makeKeyAndVisible()
    }
}

class UserDefaultsKey {
    static let bioAuthEnabled = "BioAuthEnabled"
    static let profileToken = "ProfileToken"
}

/// Coordinator for app root scene (RootNavigationTabBarViewController)
class RootCoordinator: Coordinator {
    let navigationController: MainNavController
    let rootViewController: MVCRootNavTabBarEntryViewController

    // MARK: - initializer

    override init() {
        rootViewController = MVCRootNavTabBarEntryViewController()
        navigationController = RootNavigationController(rootViewController: rootViewController)
        navigationController.setupContentByTheme()
    }

}
