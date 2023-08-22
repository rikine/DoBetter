//
//  SignInCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias SignInScene = VIPScene<SignInViewController, SignInInteractor, SignInPresenter>

class SignInCoordinator: ChainedNavigationCoordinator<SignInScene>, BioAuthCoordinating {
    init(on: MainNavController) {
        super.init(on: on, root: SignInScene())
        root.interactor.coordinator = self
    }

    func showSignUp(screenType: SignUp.ScreenType) {
        SignUpCoordinator(on: navigationController).start(in: self)
    }

    func showCodeEnter(phone: String, _ onResult: @escaping (Bool) -> Void) {
        PhoneCodeEnterCoordinator(on: navigationController, phone: phone).onResult(onResult).start(in: self)
    }
}
