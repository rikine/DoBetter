//
// Created by Никита Шестаков on 04.03.2023.
//

import Foundation
import UIKit

protocol MessageActionDelegate: AnyObject {
    func performAction(action: AppAction,
                       suppressUnknownCodeCheck: Bool,
                       onStandardAlertDismiss: (() -> Void)?)
}

extension MessageActionDelegate {
    func performAction(action: AppAction) {
        performAction(action: action,
                      suppressUnknownCodeCheck: false,
                      onStandardAlertDismiss: nil)
    }
}

protocol MVCRootNavTabBarEntryDataStore {
    var dataStore: MVCRootNavTabBarEntryDataStore? { get }
}

final class MVCRootNavTabBarEntryViewController: BaseViewController, ActivityIndicationDisplaying, ErrorDisplaying {

    static private(set) weak var shared: MVCRootNavTabBarEntryViewController?
    /// Assign AppLocalAction struct in order to test pushes, which route to specific screens
    static var pendingAction: AppAction?

    private(set) var rootTabBarViewController: RootNavigationTabBarViewController?
    var coordinator: (AnyCoordinator & AnySceneCoordinator)?

    var dataStore: MVCRootNavTabBarEntryDataStore?
    var application: UIApplication = UIApplication.shared
    var userDefaults: UserDefaults = .standard

    override func viewDidLoad() {
        super.viewDidLoad()

        _setupNextViewController()

        MVCRootNavTabBarEntryViewController.shared = self
    }

    private func _setupNextViewController() {
        Task { @MainActor in
            do {
                let token = try await FirebaseAuthService.shared.getToken()
                print(token)
            } catch {
                if CommandLine.arguments.contains("test") {
                    self.userDefaults.set("test1", forKey: UserDefaultsKey.profileToken)
                } else {
                    NetworkService.shared.clear()
                    AppCoordinator.shared.start()
                    return
                }
            }

            let nextController = RootNavigationTabBarViewController()
            self.navigationController?.pushViewController(nextController, animated: false)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.rootTabBarViewController = nextController

            Self.pendingAction.let(self.performAction)
        }
    }
}

extension MVCRootNavTabBarEntryViewController: MessageActionDelegate {

    enum Error: Swift.Error {
        case noViewControllerForLocalAction
        case noData
    }

    private static func createNavigationController(rootViewController: UIViewController?) -> RootNavigationController {
        let navigationController = rootViewController.map { RootNavigationController(rootViewController: $0) } ?? RootNavigationController()
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.titleTextAttributes
            = [.font: UIFont.systemFont(ofSize: 17, weight: .medium),
               .foregroundColor: UIColor.white]
        return navigationController
    }

    private func _getDestinationCoordinator(for action: AppLocalAction) -> MainNavController? {
        guard let data = MVCRootNavTabBarEntryViewController._actionCoordinatorData(action: action.section)
        else { return nil }
        switch data.coordinatorClass {
        default:
            return nil
        }
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func performAction(action: AppAction,
                       suppressUnknownCodeCheck: Bool,
                       onStandardAlertDismiss: (() -> Void)? = nil) {
        switch action {
        case let action as AppLocalAction:
            /// Add open logic
            if let pending = MVCRootNavTabBarEntryViewController.pendingAction as? AppLocalAction,
               action == pending {
                MVCRootNavTabBarEntryViewController.pendingAction = nil
            }
        case let action as AppExternalAction:
            _checkAndOpenURL(action.url)
            if let pending = MVCRootNavTabBarEntryViewController.pendingAction as? AppExternalAction,
               action == pending {
                MVCRootNavTabBarEntryViewController.pendingAction = nil
            }
        default:
            break
        }
    }

    private func _checkAndOpenURL(_ url: URL) {
        guard url.scheme != nil else {
            displayError(.init(message: "Некорректная ссылка"))
            return
        }
        UIApplication.shared.open(url)
    }
}

protocol ModalAppActionViewController {}

extension MVCRootNavTabBarEntryViewController {
    struct ActionCoordinatorData {
        let coordinatorClass: AnyCoordinator.Type
    }

    private static func _actionCoordinatorData(action: LocalAction) -> ActionCoordinatorData? {
        nil
    }
}


class RootNavigationController: MainNavController {
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarHidden(true, animated: animated)
    }
}
