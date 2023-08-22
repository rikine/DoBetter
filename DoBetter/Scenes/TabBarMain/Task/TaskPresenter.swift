//
//  TaskPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 18.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol TaskPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: TaskModels.Table.Response)
}

class TaskPresenter: TaskPresentationLogic,
                     TablePresenting,
                     PresentingType,
                     Initializable {

    typealias Task = Localization.Task

    weak var viewController: TaskDisplayLogic?

    var sections: [Table.SectionViewModel] = []

    required init() {}

    func presentTable(_ response: TaskModels.Table.Response) {
        sections = .single(
            with: [makeSectionModel(task: response.task),
                   makeTitle(task: response.task),
                   makeTimerAndOwner(task: response.task, user: response.user),
                   makeDescription(task: response.task),
                   makeCreationDate(task: response.task),
                   uploadImage(task: response.task)].flatten()
        )

        viewController?.displayEditable(.init(isEditable: response.task.isEditable))
        viewController?.displayLikes(.init(count: String(response.task.likesCount),
                                           status: response.task.isDone
                                               ? Task.done.localized
                                               : (response.task.isInProgress
                                                    ? Task.inProgress.localized
                                                    : Task.new.localized),
                                           isLiked: response.task.isLiked,
                                           isLikeLoading: response.isLikeLoading))
        viewController?.displaySlider(.init(title: response.task.isInProgress
            ? Task.setAsDone.localized
            : (response.task.isDone ? Task.setAsNew.localized : Task.setAsInProgress.localized)))
        viewController?.displayBackgroundColor(.init(color: response.task.color.uiColor.withAlphaComponent(response.task.color.uiColor.alpha * 0.1)))
        viewController?.displayTable(.init(sections: sections))
    }

    private func makeSectionModel(task: TaskModel) -> TaskSectionPickerView.CollectionFlow? {
        if task.section != .none {
            return .init(items: [TaskSectionPickerView.CollectionCell.Model(.init(section: task.section, isSelected: false))],
                         itemSize: .square(40),
                         scrollBehaviour: .plain,
                         isExpandSingleItemEnabled: false,
                         preselectedIndexAlwaysUpdate: false,
                         backgroundColor: .clear)
        }

        return nil
    }

    private func makeTitle(task: TaskModel) -> TextCell.Cell.Model {
        .init(.init(text: task.title.apply(style: .headline.foreground.multiline)), padding: .horizontal(16) + .top(20) + .bottom(12))
    }

    private func makeDescription(task: TaskModel) -> TextCell.Cell.Model? {
        task.description.emptyLet.map {
            .init(.init(label: Task.description.localized.attrString, text: $0.apply(style: .body)), padding: .horizontal(16) + .vertical(12))
        }
    }

    private func makeCreationDate(task: TaskModel) -> TextCell.Cell.Model {
        .init(.init(label: Task.createdAt.localized.attrString,
                    text: DateFormatter.taskFull.string(from: task.createdAt).attrString.apply(.body)),
              padding: .horizontal(16) + .vertical(12))
    }

    private func makeTimerAndOwner(task: TaskModel, user: ProfileModel?) -> TimeAndOwnerTaskView.Cell.Model {
        .init(.init(user: user.map {
            .init(icon: .init(url: $0.photoUrl, placeholder: $0.initialsImage(with: .bigSquircle), style: .big),
                  nickname: ($0.name ?? $0.nickname).apply(style: .body))
        }, endDate: task.endDate), padding: .horizontal(16) + .vertical(8))
    }

    private func uploadImage(task: TaskModel) -> UploadImageView.Cell.Model? {
        task.imageUrl.map {
            .init(.init(image: .init(url: $0, placeholder: .Task.empty.glyphSize(.square(80)), style: .large)))
        }
    }
}
