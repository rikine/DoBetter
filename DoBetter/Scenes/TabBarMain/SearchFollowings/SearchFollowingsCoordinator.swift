//
//  SearchFollowingsCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias SearchFollowingsScene = VIPScene<SearchFollowingsViewController, SearchFollowingsInteractor, SearchFollowingsPresenter>

class SearchFollowingsCoordinator: ChainedNavigationCoordinator<SearchFollowingsScene> {
    init(on: MainNavController, for profile: ProfileModel? = nil, type: SearchFollowings.SearchType = .all) {
        super.init(on: on, root: SearchFollowingsScene(interactor: .init(for: profile, type: type)))
        root.interactor.coordinator = self
        root.viewController.hidesBottomBarWhenPushed = true
    }

    func showProfile(_ profile: ProfileModel) {
        ProfileCoordinator(on: navigationController, uid: profile.uid).start(in: self)
    }

    func showSearchHidden() {
        HiddenProfileSearchCoordinator(on: navigationController)
            .onResult(showProfile)
            .start(in: self)
    }
}
