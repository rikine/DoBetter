//
//  SignUpCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 07.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation
import UIKit

typealias SignUpScene = VIPScene<SignUpViewController, SignUpInteractor, SignUpPresenter>

class SignUpCoordinator: ChainedNavigationCoordinator<SignUpScene>, BioAuthCoordinating {
    init(on: MainNavController, screenType: SignUp.ScreenType = .email) {
        super.init(on: on, root: SignUpScene(interactor: .init(screenType: screenType)))
        root.interactor.coordinator = self
    }

    func showSignIn() {
        navigationController.popViewController(animated: true)
    }

    func showCodeEnter(nickname: String, phone: String, _ onResult: @escaping (Bool) -> Void) {
        PhoneCodeEnterCoordinator(on: navigationController, phone: phone, nickname: nickname)
                .onResult(onResult)
                .start(in: self)
    }
}
