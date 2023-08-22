//
//  OtherFeedViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes

protocol OtherFeedDisplayLogic: FeedDisplayLogic {
    func displayNavBar(_ viewModel: OtherFeed.NavBar.ViewModel)
}

class OtherFeedViewController: FeedViewController<OtherFeedInteractor>,
                               OtherFeedDisplayLogic {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Localization.OtherFeed.title.localized
        interactor?.loadV2(.initial)
    }

    func displayNavBar(_ viewModel: OtherFeed.NavBar.ViewModel) {
        guard viewModel.isCurrent else {
            navigationItem.title = Localization.Profile.tasksLabel.localized
            bottomView?.border(nil)
            return
        }

        navigationItem.title = Localization.OtherFeed.title.localized

        navigationItem.rightBarButtonItem = .makeCustomItem(iconModel: .User.loupe) { [weak self] in
            self?.interactor?.showUsers(.init())
        }
    }
}
