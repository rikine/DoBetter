//
//  OtherFeedCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias OtherFeedScene = VIPScene<OtherFeedViewController, OtherFeedInteractor, OtherFeedPresenter>

class OtherFeedCoordinator: ChainedNavigationCoordinator<OtherFeedScene> {
    init(on: MainNavController, forUserUid: String? = nil) {
        super.init(on: on, root: OtherFeedScene(interactor: .init(userUid: forUserUid),
                                                presenter: .init(isCurrent: forUserUid == nil)))
        root.interactor.coordinator = self
    }

    func showUsers() {
        SearchFollowingsCoordinator(on: navigationController, type: .all).start(in: self)
    }

    func showProfile(for uid: String) {
        ProfileCoordinator(on: navigationController, uid: uid).start(in: self)
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
