//
//  TaskViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 18.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes
import MTSlideToOpen

protocol TaskDisplayLogic: TableDisplayLogic {
    func displayLikes(_ viewModel: TaskModels.Likes.ViewModel)
    func displayEditable(_ viewModel: TaskModels.Editable.ViewModel)
    func displayBackgroundColor(_ viewModel: TaskModels.BackgroundColor.ViewModel)
    func displaySlider(_ viewModel: TaskModels.Slider.ViewModel)
}

class TaskViewController: TableViewNodeController,
                          TaskDisplayLogic,
                          TableDisplaying,
                          SnackNotificationDisplayer {

    weak var interactor: TaskBusinessLogic?

    override var isBottomViewNeeded: Bool { true }

    override var cellModelTypes: [CellViewAnyModel.Type] {
        [BottomSheetHeadlineView.Cell.Model.self,
         TextCell.Cell.Model.self,
         UploadImageView.Cell.Model.self,
         TaskSectionPickerView.CollectionFlow.self,
         TimeAndOwnerTaskView.Cell.Model.self]
    }

    private var statusText: Text!
    private var likesText: Text!
    private var like: RoundCornersButton!
    private var slider: UIViewWrapper<MTSlideToOpenView>!

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
        navigationItem.title = Localization.Task.title.localized

        bottomViewStack?.background(color: .clear)

        interactor?.loadV2(.initial)
    }

    override func refresh() {
        super.refresh()
        interactor?.loadV2(.pullToRefresh)
    }

    override func makeBottomView() -> View {
        VStack().padding(.horizontal(16) + .vertical(8)).spacing(4).config(backgroundColor: .clear).content {
            HStack().width(.fill).content {
                View().padding(.all(4) + .horizontal(4)).corner(radius: 8).border(color: .foreground4).content {
                    statusText = Text()
                }

                HStack().spacing(4).content {
                    likesText = Text()

                    HStack().alignment(.center).content {
                        like = RoundCornersButton().action { [weak interactor] in
                                    interactor?.onLike(.init())
                                }.size(24).corner(radius: 8)
                    }
                }
            }

            slider = UIViewWrapper(MTSlideToOpenView(frame: CGRect(x: 26, y: 400, width: 317, height: 56)))
                    .config(backgroundColor: .clear)
        }
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as UploadImageView.Cell, _):
            cell.mainView.info.hidden(true)
            cell.mainView.remove.hidden(true)
            cell.mainView.corner(radius: 12).background(color: .content2).padding(.all(8))
            cell.wrapperView.padding(.horizontal(16))
        case (let cell as TextCell.Cell, _):
            cell.mainView.corner(radius: 12).background(color: .content2).padding(.all(8))
        case (let cell as TimeAndOwnerTaskView.Cell, _):
            cell.mainView.corner(radius: 12).background(color: .content2).padding(.all(8))

            cell.mainView.userView.onTap { [weak interactor] in
                interactor?.onProfile(.init())
            }
        default: break
        }
    }

    func displayBackgroundColor(_ viewModel: TaskModels.BackgroundColor.ViewModel) {
        tableView.backgroundColor = viewModel.color
    }

    func displaySlider(_ viewModel: TaskModels.Slider.ViewModel) {
        UIView.animate(withDuration: 0.2) {
            let slider = self.slider
            slider?.wrapped.labelText = viewModel.title
            slider?.wrapped.delegate = self
            slider?.wrapped.sliderCornerRadius = 16
            slider?.wrapped.sliderBackgroundColor = .accent.withAlphaComponent(0.5)
            slider?.wrapped.slidingColor = .accent.withAlphaComponent(0.7)
            slider?.wrapped.thumbnailColor = .accent
            slider?.wrapped.textColor = .elevated
        }
    }

    func displayLikes(_ viewModel: TaskModels.Likes.ViewModel) {
        UIView.animate(withDuration: 0.2) {
            RoundCornersButton.Model(text: nil,
                                     iconModel: viewModel.isLiked ? .Task.heartFill : .Task.heart,
                                     style: .text,
                                     isEnabled: !viewModel.isLikeLoading,
                                     isLoading: viewModel.isLikeLoading,
                                     height: 24,
                                     width: 24)
                    .setup(view: self.like)
            let interactor = self.interactor
            self.like.action { [weak interactor] in
                interactor?.onLike(.init())
            }

            self.likesText.text(viewModel.count.apply(style: .body.foreground))
            self.statusText.text(viewModel.status.apply(style: .body.foreground))

            self.view.layoutSubviewsRecursively()
        }
    }

    func displayEditable(_ viewModel: TaskModels.Editable.ViewModel) {
        if viewModel.isEditable {
            navigationItem.rightBarButtonItems = [
                .makeCustomItem(iconModel: .Task.remove.glyphSize(.square(20))) { [weak interactor] in
                    interactor?.onRemove(.init())
                }, .makeCustomItem(iconModel: .User.pen.glyphSize(.square(20))) { [weak interactor] in
                    interactor?.onEdit(.init())
                }
            ]
        } else {
            slider?.hidden(true)
        }
    }
}

extension TaskViewController: MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpen.MTSlideToOpenView) {
        interactor?.onDone(.init())

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak sender] in
            sender?.resetStateWithAnimation(true)
        }
    }
}
