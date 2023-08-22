//
//  MyFeedCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias MyFeedScene = VIPScene<MyFeedViewController, MyFeedInteractor, MyFeedPresenter>

class MyFeedCoordinator: ChainedNavigationCoordinator<MyFeedScene> {
    init(on: MainNavController) {
        super.init(on: on, root: MyFeedScene())
        root.interactor.coordinator = self
    }

    func showProfile() {
        ProfileCoordinator(on: navigationController, uid: FirebaseAuthService.shared.getCurrentUid ?? "current").start(in: self)
    }

    func showCreateTask() {
        CreateTaskCoordinator(on: navigationController).start(in: self)
    }

    func showFilters(model: MyFeed.Filters) {
        MyFeedFiltersCoordinator(on: navigationController, model: model)
                .onResult { [weak root] model in
                    root?.interactor.updateFilters(model: model)
                }.start(in: self)
    }

    func showTask(with model: TaskModel) {
        TaskCoordinator(on: navigationController, taskModel: model).start(in: self)
    }
}
