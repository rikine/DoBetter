//
//  SettingsCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 16.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias SettingsScene = VIPScene<SettingsViewController, SettingsInteractor, SettingsPresenter>

class SettingsCoordinator: ChainedNavigationCoordinator<SettingsScene> {
    init(on: MainNavController, isProfileSecure: Bool) {
        super.init(on: on, root: SettingsScene(interactor: .init(isSecureProfile: isProfileSecure)))
        root.interactor.coordinator = self
    }
}
