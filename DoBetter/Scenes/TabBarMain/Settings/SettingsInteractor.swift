//
//  SettingsInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 16.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

protocol SettingsBusinessLogic: TableBusinessLogic {
    func onBioAuth(_ request: BioAuth.Suggest.Request)
    func exit(_ request: Settings.Exit.Request)
}

class SettingsInteractor: SettingsBusinessLogic,
                          InteractingType,
                          FlagLoadingType {

    var presenter: SettingsPresentationLogic?
    var worker = SettingsWorker()
    weak var coordinator: SettingsCoordinator?

    var isLoading = false

    private var isSecureProfile: Bool
    private var isFaceIDEnabled: Bool {
        (UserDefaults.standard.value(forKey: UserDefaultsKey.bioAuthEnabled) as? Bool) ?? false
    }

    required init(isSecureProfile: Bool) {
        self.isSecureProfile = isSecureProfile
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        presenter?.presentTable(.init(isFaceIDEnabled: isFaceIDEnabled, isSecureProfileEnabled: isSecureProfile))
    }

    func didSelectRow(_ request: Table.Selection.Request) {
        guard !isLoading else { return }
        guard let payload = request.payload as? Settings.Setting else { return }

        Task { @MainActor in
            do {
                switch payload {
                case .bioAuth:
                    if isFaceIDEnabled {
                        presenter?.presentBioAuthAlert(.init())
                    } else {
                        UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.bioAuthEnabled)
                    }
                case .secure:
                    try await worker.makeSecure()
                    isSecureProfile.toggle()
                }
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            presentTable()
            finishLoading()
        }
    }

    func onBioAuth(_ request: BioAuth.Suggest.Request) {
        guard !request.isCanceled else {
            presentTable()
            return
        }

        UserDefaults.standard.setValue(false, forKey: UserDefaultsKey.bioAuthEnabled)
        presentTable()
    }

    func exit(_ request: Settings.Exit.Request) {
        NetworkService.shared.clear()
        MVCRootNavTabBarEntryViewController.shared?.rootTabBarViewController?.dismiss()
        AppCoordinator.shared.clear()
    }

    private func presentTable() {
        presenter?.presentTable(.init(isFaceIDEnabled: isFaceIDEnabled, isSecureProfileEnabled: isSecureProfile))
    }
}
