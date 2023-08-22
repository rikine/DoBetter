//
// Created by Никита Шестаков on 12.03.2023.
//

import Foundation
import UIKit

enum BioAuth {
    enum Suggest {
        struct Request {
            let isCanceled: Bool
        }
        struct Response {}
    }
}

protocol BioAuthCoordinating: AnyObject {
    func showNext()
}

extension BioAuthCoordinating {
    func showNext() {
        AppCoordinator.shared.start()
    }
}

protocol BioAuthBusinessLogic: AnyObject {
    func onBioAuth(_ request: BioAuth.Suggest.Request)
}

protocol BioAuthInteracting: BioAuthBusinessLogic {
    associatedtype Coordinator: BioAuthCoordinating
    var coordinator: Coordinator? { get }
}

extension BioAuthInteracting {
    func onBioAuth(_ request: BioAuth.Suggest.Request) {
        UserDefaults.standard.set(!request.isCanceled, forKey: UserDefaultsKey.bioAuthEnabled)
        coordinator?.showNext()
    }
}

protocol BioAuthPresentationLogic {
    func presentBioAuthAlert(_ response: BioAuth.Suggest.Response)
}

protocol BioAuthPresenting: BioAuthPresentationLogic, PresentingType {
    var bioAuthViewController: BioAuthDisplayLogic? { get }
}

extension BioAuthPresenting {
    var bioAuthViewController: BioAuthDisplayLogic? {
        assertionCast(viewController, to: BioAuthDisplayLogic.self)
    }

    func presentBioAuthAlert(_ response: BioAuth.Suggest.Response) {
        bioAuthViewController?.displayBioAuthAlert(.init())
    }
}

protocol BioAuthDisplayLogic {
    func displayBioAuthAlert(_ response: BioAuth.Suggest.Response)
}

protocol BioAuthDisplaying: UIViewController, BioAuthDisplayLogic, DisplayingType {
    var bioAuthInteractor: BioAuthBusinessLogic? { get }

    func displayBioAuthAlert(_ response: BioAuth.Suggest.Response)
}

extension BioAuthDisplaying {
    var bioAuthInteractor: BioAuthBusinessLogic? {
        assertionCast(interactor, to: BioAuthBusinessLogic.self)
    }

    func displayBioAuthAlert(_ response: BioAuth.Suggest.Response) {
        let alert = UIAlertController(title: Localization.BioAuth.titleAlert.localized,
                                      message: Localization.BioAuth.subtitleAlert.localized,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: Localization.ok.localized, style: .default) { [weak bioAuthInteractor] _ in
            bioAuthInteractor?.onBioAuth(.init(isCanceled: false))
        })
        alert.addAction(.init(title: Localization.cancel.localized, style: .destructive) { [weak bioAuthInteractor] _ in
            bioAuthInteractor?.onBioAuth(.init(isCanceled: true))
        })
        alert.preferredAction = alert.actions.first

        present(alert, animated: true)
    }
}
