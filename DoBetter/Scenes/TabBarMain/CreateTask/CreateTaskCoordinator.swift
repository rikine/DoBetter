//
//  CreateTaskCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 03.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation
import SPStorkController

typealias CreateTaskScene = VIPScene<CreateTaskViewController, CreateTaskInteractor, CreateTaskPresenter>

class CreateTaskCoordinator: ChainedDrawerCoordinator<CreateTaskScene>,
                             TableDrawerCoordinating {
    init(on viewController: UIViewController, model: TaskModel? = nil, type: CreateTask.ActionType = .new) {
        super.init(onPresenting: viewController,
                   withNavigation: false,
                   root: CreateTaskScene(interactor: .init(model: model, type: type)))
        root.interactor.coordinator = self
    }

    override func modifyTransitionDelegate(_ transitionDelegate: SPStorkTransitioningDelegate) {
        super.modifyTransitionDelegate(transitionDelegate)
        transitionDelegate.customHeight = tableDrawerHeight
    }

    func updateHeight() {
        tableDrawerHeight.let(changeDrawerHeight)
    }
}
