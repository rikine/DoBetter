//
//  SearchFollowingsViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes

protocol SearchFollowingsDisplayLogic: TableDisplayLogic {
    func displayFollowUser(_ viewModel: SearchFollowings.Follow.ViewModel)
    func displaySearchHidden(_ viewModel: SearchFollowings.NavBar.ViewModel)
}

class SearchFollowingsViewController: TableViewNodeController,
                                      SearchFollowingsDisplayLogic,
                                      TableDisplaying,
                                      SnackNotificationDisplayer {

    weak var interactor: SearchFollowingsBusinessLogic?
    override var hasDefaultPaging: Bool { true }
    override var isRefreshControlNeeded: Bool { false }
    override var cellModelTypes: [CellViewAnyModel.Type] {
        [SearchUserView.Cell.Model.self, InputCell.Model.self]
    }

    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.SearchUsers.users.localized
        interactor?.loadV2(.initial)

        hideKeyboardWhenTappedAround()
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as SearchUserView.Cell, let model as SearchUserView.Cell.Model):
            cell.mainView.onTap { [weak interactor] in
                guard let user = model.payload as? ProfileModel else { return }
                interactor?.showUser(.init(user: user))
            }
        case (let cell as InputCell, _):
            cell.input.didChange = { [weak self] field in
                self?.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self?.interactor?.search(.init(text: field.text))
                }
            }
        default: break
        }
    }

    func displayFollowUser(_ viewModel: SearchFollowings.Follow.ViewModel) {
        interactor?.followUser(.init(user: viewModel.user))
    }

    func displaySearchHidden(_ viewModel: SearchFollowings.NavBar.ViewModel) {
        navigationItem.rightBarButtonItem = .makeCustomItem(iconModel: .User.loupe) { [weak interactor] in
            interactor?.searchHidden(.init())
        }
    }
}
