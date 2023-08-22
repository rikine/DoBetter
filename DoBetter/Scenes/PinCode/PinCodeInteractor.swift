//
//  PinCodeInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

protocol PinCodeBusinessLogic: TableBusinessLogic {
    func tryToAuth(_ request: PinCode.TryToAuth.Request)
    func exit(_ request: PinCode.Exit.Request)
}

class PinCodeInteractor: PinCodeBusinessLogic,
                         InteractingType,
                         FlagLoadingType {

    var presenter: PinCodePresentationLogic?
    var worker = PinCodeWorker()
    weak var coordinator: PinCodeCoordinator?
    private let bioAuthService: BioAuthService
    private let userDefaults: UserDefaults

    private var bioAuthEnabled: Bool {
        userDefaults.value(forKey: UserDefaultsKey.bioAuthEnabled) as? Bool ?? false
    }

    private var profileTokenExists: Bool {
        userDefaults.value(forKey: UserDefaultsKey.profileToken) != nil
    }

    var isLoading = false

    var isPlaceholderShown = false

    required init(bioAuthService: BioAuthService = .shared, userDefaults: UserDefaults = .standard) {
        self.bioAuthService = bioAuthService
        self.userDefaults = userDefaults
    }

    func loadV2(_ request: Common.LoadV2.Request) {}

    func didSelectRow(_ request: Table.Selection.Request) {}

    func tryToAuth(_ request: PinCode.TryToAuth.Request) {
        bioAuthService.authenticateWithPasscode(reason: "", success: { [weak self] in
            self?.coordinator?.showNext(.mainTab)
        }, failure: { [weak self] error in
            switch error {
            case .biometryNotEnrolled: self?.presenter?.presentAlert(.init(alert: .bioAuthNotEnabled))
            case .passcodeNotSet: self?.presenter?.presentAlert(.init(alert: .passcodeNotSet))
            case .notAvailable: self?.presenter?.presentAlert(.init(alert: .notAvailable))
            default:
                self?.presenter?.presentAlert(.init(alert: .exit))
                self?.presenter?.presentPlaceholder(.init())
            }
        })
    }

    func exit(_ request: PinCode.Exit.Request) {
        NetworkService.shared.clear()
        coordinator?.showNext(.signIn)
    }
}

/// Увеличить время отображения для пароля, убрать пробелы у displayName у гугл входа
