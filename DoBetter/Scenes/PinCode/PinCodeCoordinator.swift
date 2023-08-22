//
//  PinCodeCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias PinCodeScene = VIPScene<PinCodeViewController, PinCodeInteractor, PinCodePresenter>

class PinCodeCoordinator: ChainedNavigationCoordinator<PinCodeScene> {
    init(on: MainNavController) {
        super.init(on: on, root: PinCodeScene(interactor: .init()))
        root.interactor.coordinator = self
    }

    func showNext(_ screen: AppCoordinator.ScreenType) {
        AppCoordinator.shared.start(screen)
    }
}
