//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

protocol ViewControllerProvider {
    var providedViewController: UIViewController { get }
}

extension UIViewController: ViewControllerProvider {
    var providedViewController: UIViewController { self }

    static func initialize() -> Self {
        makeInstance(of: self)
    }
}

protocol AnyCoordinator: AnyObject {
    func start()
    func start(in coordinator: ChainedCoordinator)
    func stop()
}

/// This Coordinator protocol is needed when some work must be delegated up to parentCoordinator.
/// For example, embeddedCoordinator reroutes navigation to it's parent.
protocol ChildCoordinator: AnyCoordinator {
    associatedtype ParentCoordinator

    /// Should be weak
    var parent: ParentCoordinator? { get set }
}

class Coordinator: AnyCoordinator {
    weak var delegate: CoordinatorDelegate?

    var isStopping = false

    func start() {}

    func start(in coordinator: ChainedCoordinator) {
        chained(in: coordinator)
        start()
    }

    @discardableResult
    func started(in coordinator: ChainedCoordinator) -> Self {
        start(in: coordinator)
        return self
    }

    /// Same as chainedCoordinator.addChain(self)
    @discardableResult
    func chained(in coordinator: ChainedCoordinator) -> Self {
        coordinator.addChain(self)
        return self
    }

    @discardableResult
    func delegate(_ coordinator: CoordinatorDelegate) -> Self {
        delegate = coordinator
        return self
    }

    func stop() {
        isStopping = true

        // call `delegate?.coordinatorDidStop(self)` when you complete stopping process
    }

    init() {
        // TODO Костыль для корректного резолвига цвета во вьюхах, создаваемых в ините VC
        UITraitCollection.current = UIApplication.topViewController.traitCollection
    }
}

protocol AnyRootProvider: AnyObject {
    var anyRoot: ViewControllerProvider { get }
}

protocol AnySceneCoordinator: AnyRootProvider, AnyCoordinator {}

/// Use when you want `where` requirements instead of casting
protocol AssociatedSceneCoordinator {
    associatedtype RootScene: ViewControllerProvider
    var root: RootScene { get }
}

extension AnyRootProvider {

    /// Use when you need to load providedViewController, but don't want to push or present it by navigation controller
    func loadProvidedViewIfNeeded() {
        anyRoot.providedViewController.loadViewIfNeeded()
    }
}

class SceneCoordinator<Scene: ViewControllerProvider>: Coordinator, AnySceneCoordinator, AssociatedSceneCoordinator {
    let root: Scene
    var anyRoot: ViewControllerProvider { root }

    init(root: Scene) {
        self.root = root
        super.init()
        Logger.lifecycle.debug("Coordinator init for \(type(of: self)) with scene \(Scene.self)")
    }

    convenience init() where Scene: Initializable {
        self.init(root: Scene())
    }

    deinit {
        Logger.lifecycle.debug("Coordinator deinit for \(type(of: self)) with scene \(Scene.self)")
    }
}

protocol CoordinatorDelegate: AnyObject {
    func coordinatorDidStop(_ coordinator: AnyCoordinator)
}
