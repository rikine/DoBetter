//
//  TaskCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 18.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias TaskScene = VIPScene<TaskViewController, TaskInteractor, TaskPresenter>

class TaskCoordinator: ChainedNavigationCoordinator<TaskScene> {
    init(on: MainNavController, taskModel: TaskModel) {
        super.init(on: on, root: TaskScene(interactor: .init(taskModel: taskModel)))
        root.interactor.coordinator = self
        root.viewController.hidesBottomBarWhenPushed = true
    }

    func showEdit(with model: TaskModel) {
        CreateTaskCoordinator(on: navigationController, model: model, type: .update).start(in: self)
    }

    func showProfile(for uid: String) {
        ProfileCoordinator(on: navigationController, uid: uid).start(in: self)
    }

    override func stop() {
        super.stop()
        navigationController.popViewController(animated: true)
    }
}
