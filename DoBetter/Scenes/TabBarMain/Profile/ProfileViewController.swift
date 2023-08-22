//
//  ProfileViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ImageViewer_swift

protocol ProfileDisplayLogic: TableDisplayLogic {
    func displayNavBar(_ viewModel: Profile.NavBar.ViewModel)
    func displayOnButtonFollowTap(_ viewModel: Profile.Button.ViewModel)
}

class ProfileViewController: TableViewNodeController,
                             ProfileDisplayLogic,
                             TableDisplaying,
                             SnackNotificationDisplayer {

    weak var interactor: ProfileBusinessLogic?

    override var cellModelTypes: [CellViewAnyModel.Type] {
        [ProfileUserView.Cell.Model.self, StatisticsView.Cell.Model.self,
         TextCell.Cell.Model.self, SpacerView.Cell.Model.self,
         UserFlowView.CollectionFlow.self, TaskView.Cell.Model.self]
    }
    override var isRefreshControlNeeded: Bool { false }

    // MARK: View lifecycle

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
        interactor?.loadV2(.initial)
    }

    override func refresh() {
        super.refresh()
        interactor?.loadV2(.pullToRefresh)
    }

    func displayNavBar(_ viewModel: Profile.NavBar.ViewModel) {
        navigationItem.title = viewModel.title

        if viewModel.isEditable {
            navigationItem.rightBarButtonItems = [.makeCustomItem(iconModel: .User.settings) { [weak interactor] in
                interactor?.onButtonTap(.edit)
            }, .makeCustomItem(iconModel: .User.pen) { [weak interactor] in
                interactor?.onButtonTap(.settings)
            }]
        }
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
//        case (let cell as ProfileUserView.Cell, _):
//            cell.mainView.image.wrapped.setupImageViewer()
        case (let cell as FlowCollectionCell, _):
            cell.collectionView.onCellDequeued = { [weak self] cell, _, model in
                guard let cell = cell as? UserFlowView.CollectionCell,
                      let model = model as? UserFlowView.CollectionCell.Model
                else { return }
                cell.mainView.onTap {
                    guard let user = model.mainViewModel.payload as? ProfileModel else { return }
                    self?.interactor?.onButtonTap(.user(model: user))
                }
            }
        case (let cell as TaskView.Cell, let model as TaskView.Cell.Model):
            guard let task = model.payload as? TaskModel else { return }

            cell.mainView.doneButton.action { [weak self] in
                self?.interactor?.onButtonTap(.doneTask(model: task))
            }

            cell.mainView.likeButton.action { [weak self] in
                self?.interactor?.onButtonTap(.likeTask(model: task))
            }

            cell.mainView.image.wrapped.setupImageViewer()

            cell.mainView.onTap { [weak self] in
                self?.interactor?.onButtonTap(.task(model: task))
            }
        case (let cell as TextCell.Cell, let model as TextCell.Cell.Model):
            guard let headline = model.payload as? Profile.Headline else { return }

            cell.mainView.rightButton.onTap { [weak self] in
                switch headline {
                case .tasks: self?.interactor?.onButtonTap(.allTasks)
                case .followers: self?.interactor?.onButtonTap(.allFollowers)
                case .followings: self?.interactor?.onButtonTap(.allFollowings)
                }
            }
        default: break
        }
    }

    func displayOnButtonFollowTap(_ viewModel: Profile.Button.ViewModel) {
        interactor?.onButtonTap(viewModel)
    }
}
