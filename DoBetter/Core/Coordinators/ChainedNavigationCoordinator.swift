//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation

import UIKit

protocol AnyChainedNavigationCoordinator: ChainedCoordinator, AnyNavigationCoordinator, AnySceneCoordinator {}

protocol AnyNavigationCoordinator: AnyCoordinator {
    var navigationController: MainNavController { get }
}

class ChainedNavigationCoordinator<Scene: ViewControllerProvider>: SceneCoordinator<Scene>,
                                                                   NavigationControllerContentChangesDelegate,
                                                                   AnyChainedNavigationCoordinator {

    /// Indicates how new view controller will appear on screen
    enum PresentationMode {
        /// navigationController.pushViewController()
        case push(animated: Bool)
        /// navigationController.present()
        case present(animated: Bool)
        /// Handle presentation logic by overriding start().
        /// You still required to call super.start() but it will not present your scene.
        case custom
    }

    var chainParent: ChainedCoordinator? {
        didSet {
            if oldValue != nil && chainParent == nil {
                dismiss()
            }
        }
    }

    var chainChildren: [AnyCoordinator] = []

    let navigationController: MainNavController

    /// Indicates how new view controller will appear on screen
    /// Set value before call start()
    public var presentationMode: PresentationMode = .push(animated: true)

    init(on: MainNavController, root: Scene) {
        navigationController = on
        super.init(root: root)
        on.addDelegate(self)
    }

    override func start() {
        super.start()
        switch presentationMode {
        case let .push(animated):
            navigationController.pushViewController(root.providedViewController, animated: animated)
        case let .present(animated):
            navigationController.present(root.providedViewController, animated: animated)
        case .custom:
            break
        }
    }

    deinit {
        navigationController.removeDelegate(self)
        dismiss()
    }

    // FIXME
    func dismiss(animated: Bool = true) {
        let viewControllers = navigationController.viewControllers
        // Когда дисмисс вызывается НЕ на последнем координаторе в цепочке, у чайлдов тоже вызывается этот метод (из chainParent.didSet/deinit)
        // На iOS > 13 в момент, когда setViewControllers анимация не закончена, последний контроллер в стеке становится первым ( ͡° ͜ʖ ͡°)
        // И в его дисмиссе он убирает с navigationController вообще все контроллеры, так что проверяем индекс на адекватность
        guard let index: Int = viewControllers.firstIndex(of: root.providedViewController),
              index > 0 else { return }

        let slice = viewControllers[viewControllers.startIndex..<index]
        navigationController.setViewControllers(Array(slice), animated: animated)
    }

    func didPushViewController(_ viewController: UIViewController) {
        if viewController === root.providedViewController {
            chainParent?.addChain(self)
        }
    }

    func didPopViewController(_ viewController: UIViewController) {
        if viewController === root.providedViewController {
            delegate?.coordinatorDidStop(self)
            removeSelfChain()
        }
    }

    func didSetViewControllers(_ viewControllers: [UIViewController]) {
        if viewControllers.contains(root.providedViewController) {
            chainParent?.addChain(self)
        } else {
            removeSelfChain()
        }
    }

    func handleEvent(_ event: CoordinatorEvent) {
        chainParent?.handleEvent(event)
    }

    func stop(replacing replacement: ChainedCoordinator) {
        assertionFailure("Not implemented in \(type(of: self))")
    }
}
