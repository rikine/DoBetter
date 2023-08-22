//
//  MyFeedViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes

protocol FeedDisplayLogic: TableDisplayLogic {
    func displayFiltersCount(_ response: MyFeed.FilterCount.ViewModel)
}

class FeedViewController<Interactor: FeedBusinessLogic>: TableViewNodeController,
                                                         TableDisplaying,
                                                         FeedDisplayLogic,
                                                         SnackNotificationDisplayer {
    weak var interactor: Interactor?

    override var isBottomViewNeeded: Bool { true }
    override var cellModelTypes: [CellViewAnyModel.Type] {
        [TaskView.Cell.Model.self, InputCell.Model.self]
    }
    override var hasDefaultPaging: Bool { true }

    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var filtersButton: RoundCornersButton!

    // MARK: View lifecycle

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }

    override func refresh() {
        super.refresh()
        interactor?.loadV2(.pullToRefresh)
    }

    override func makeBottomView() -> View {
        HStack()
                .padding(.all(4))
                .config(backgroundColor: .clear)
                .background(color: .background2)
                .corner(radius: 12, corners: [.topLeft, .topRight])
                .border(color: .accent)
                .content {
                    filtersButton = RoundCornersButton()
                            .title(Localization.MyFeed.filters.localized)
                            .style(.primary)
                            .height(40)
                            .padding(.all(4))
                            .width(Localization.MyFeed.filters.localized.style(.body.semibold).size().width + 32 + 32)
                            .action { [weak interactor] in
                                interactor?.showFilters(.init())
                            }

                    View().width(.fill)

                    makeCreateTaskImage()
                }
    }

    func makeCreateTaskImage() { }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as TaskView.Cell, let model as TaskView.Cell.Model):
            guard let task = model.payload as? TaskModel else { break }
            cell.mainView.onTap { [weak interactor] in
                interactor?.showTask(.init(model: task))
            }

            cell.mainView.likeButton.action { [weak interactor] in
                interactor?.onLikeTask(.init(task: task))
            }

            cell.mainView.doneButton.action { [weak interactor] in
                interactor?.onDoneTask(.init(task: task))
            }

            cell.mainView.name.onTap { [weak interactor] in
                interactor?.showProfile(.init(uid: task.ownerUID))
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomViewStack?.padding(.bottom(view.safeAreaInsets.bottom - 1) + .horizontal(8))
    }

    func displayFiltersCount(_ response: MyFeed.FilterCount.ViewModel) {
        guard let count = response.count else {
            filtersButton.icon(nil)
            return
        }

        filtersButton.icon(.fromText(String(count),
                                     textStyle: .line,
                                     shape: .smallCircle,
                                     shapeColor: .white,
                                     glyphTintColor: .black), imageInsets: .right(8))
                .width(Localization.MyFeed.filters.localized.style(.body.semibold).size().width + 32 + 32)
        view.layoutSubviewsRecursively()
    }
}

protocol MyFeedDisplayLogic: FeedDisplayLogic { }

class MyFeedViewController: FeedViewController<MyFeedInteractor>,
                            MyFeedDisplayLogic {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Localization.MyFeed.title.localized
        navigationItem.rightBarButtonItem = .makeCustomItem(iconModel: .SingIn.user) { [weak self] in
            self?.interactor?.showProfile(.init(uid: nil))
        }
        
        interactor?.loadV2(.initial)
    }

    override func makeCreateTaskImage() {
        let image = Image()
                .size(40)
                .icon(.Task.plus)
                .onTap { [weak interactor] in
                    interactor?.showCreateTask(.init())
                }
        image.wrapped.accessibilityLabel = "CreateTask"
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let model = sections[optional: indexPath] as? TaskView.Cell.Model,
              let payload = model.payload as? TaskModel
        else { return nil }

        return .init(actions: [.init(style: .destructive, title: Localization.remove.localized) { [weak interactor] _, _, closure in
            interactor?.onRemove(.init(model: payload))
            closure(true)
        }])
    }
}
