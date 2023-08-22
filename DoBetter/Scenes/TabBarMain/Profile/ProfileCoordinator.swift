//
//  ProfileCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

typealias ProfileScene = VIPScene<ProfileViewController, ProfileInteractor, ProfilePresenter>

/// О сцене:
/// - краткое описание
/// - как попасть на экран
///
/// Figma:
///
class ProfileCoordinator: ChainedNavigationCoordinator<ProfileScene> {
    init(on: MainNavController, uid: String) {
        super.init(on: on, root: ProfileScene(interactor: .init(uid: uid)))
        root.interactor.coordinator = self
        root.viewController.hidesBottomBarWhenPushed = true
    }

    func showEdit(with model: ProfileModel) {
        ProfileEditCoordinator(on: navigationController, profile: model).start(in: self)
    }

    func showProfile(with model: ProfileModel) {
        ProfileCoordinator(on: navigationController, uid: model.uid).start(in: self)
    }

    func showUsers(for model: ProfileModel, with type: SearchFollowings.SearchType) {
        SearchFollowingsCoordinator(on: navigationController, for: model, type: type).start(in: self)
    }

    func showSettings(for model: ProfileModel) {
        SettingsCoordinator(on: navigationController, isProfileSecure: model.isSecure).start(in: self)
    }

    func showTask(for model: TaskModel) {
        TaskCoordinator(on: navigationController, taskModel: model).start(in: self)
    }

    func showFollowingsTask(for model: ProfileModel) {
        OtherFeedCoordinator(on: navigationController, forUserUid: model.uid).start(in: self)
    }
}
