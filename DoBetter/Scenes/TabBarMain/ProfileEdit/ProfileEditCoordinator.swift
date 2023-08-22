//
//  ProfileEditCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias ProfileEditScene = VIPScene<ProfileEditViewController, ProfileEditInteractor, ProfileEditPresenter>

class ProfileEditCoordinator: ChainedNavigationCoordinator<ProfileEditScene> {
    init(on: MainNavController, profile: ProfileModel) {
        super.init(on: on, root: ProfileEditScene(interactor: .init(profile: profile)))
        root.interactor.coordinator = self
    }

    func showProfile() {
        navigationController.popViewController(animated: true)
    }
}
