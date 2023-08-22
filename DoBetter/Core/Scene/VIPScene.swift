//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

protocol InteractingType {
    associatedtype Presenter
    var presenter: Presenter? { get set }
}

protocol AnyPresentingType {
    var anyViewController: UIViewController? { get }
}

protocol PresentingType: AnyPresentingType {
    associatedtype ViewController
    var viewController: ViewController? { get set }
}

extension PresentingType {
    var anyViewController: UIViewController? { viewController as? UIViewController }
}

protocol DisplayingType {
    associatedtype Interactor
    var interactor: Interactor? { get set }
}

protocol VIPSceneProvider: ViewControllerProvider {
    associatedtype Interactor: InteractingType
    associatedtype Presenter: PresentingType
    var interactor: Interactor { get }
    var presenter: Presenter { get }
}

final class VIPScene<V: DisplayingType & UIViewController,
                    I: InteractingType,
                    P: PresentingType> {

    let viewController: V
    let interactor: I
    let presenter: P

    init(viewController: V = makeInstance(of: V.self), interactor: I, presenter: P = makeInstance(of: P.self)) {

        var viewController = viewController
        var interactor = interactor
        var presenter = presenter

        if let vcInteractor = interactor as? V.Interactor {
            viewController.interactor = vcInteractor
        } else {
            assertionFailure("interactor of type \(type(of: interactor)) must conform to \(V.Interactor.self)")
        }

        if let intPresenter = presenter as? I.Presenter {
            interactor.presenter = intPresenter
        } else {
            assertionFailure("presenter of type \(type(of: presenter)) must conform to \(I.Presenter.self)")
        }

        if let vc = viewController as? P.ViewController {
            presenter.viewController = vc
        } else {
            assertionFailure("viewController of type \(type(of: viewController)) must conform to \(P.ViewController.self)")
        }

        self.interactor = interactor
        self.presenter = presenter
        self.viewController = viewController
    }

    init?(from viewController: V, interactorType: I.Type, presenterType: P.Type) {
        guard let interactor = viewController.interactor as? I, let presenter = interactor.presenter as? P else {
            return nil
        }
        self.viewController = viewController
        self.interactor = interactor
        self.presenter = presenter
    }
}

extension VIPScene: VIPSceneProvider {
    var providedViewController: UIViewController { viewController }
}

extension VIPScene: Initializable where I: Initializable, P: Initializable {
    convenience init() {
        self.init(viewController: makeInstance(of: V.self), interactor: I(), presenter: P())
    }
}

extension VIPScene where I: Initializable, P: Initializable {
    convenience init(viewController: V) {
        self.init(viewController: viewController, interactor: I(), presenter: P())
    }
}

extension VIPScene where P: Initializable {
    convenience init(viewController: V, interactor: I) {
        self.init(viewController: viewController, interactor: interactor, presenter: P())
    }

    convenience init(interactor: I) {
        self.init(viewController: makeInstance(of: V.self), interactor: interactor, presenter: P())
    }
}
