//
//  ProfilePresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol ProfilePresentationLogic: TablePresentationLogic {
    func presentTable(_ response: Profile.Table.Response)
    func presentTasks(_ response: Profile.Tasks.Response)
    func presentUsers(_ response: Profile.Users.Response)
    func presentStatistics(_ response: Profile.Statistics.Response)
}

class ProfilePresenter: ProfilePresentationLogic,
                        TablePresenting,
                        PresentingType,
                        Initializable {

    typealias ProfileStrings = Localization.Profile

    weak var viewController: ProfileDisplayLogic?

    private static let padding: UIEdgeInsets = .horizontal(16) + .vertical(8)

    var sections: [Table.SectionViewModel] {
        sectionsOrEmpty(for: profileUserModel, label: nil, text: nil)
            + sectionsOrEmpty(for: descriptionModel, label: nil, text: nil)
            + sectionsOrEmpty(for: taskStatistics, label: ProfileStrings.statisticsLabel.localized, text: ProfileStrings.statisticsPlaceholder.localized)
            + sectionsOrEmpty(for: tasksModel, label: ProfileStrings.tasksLabel.localized, text: ProfileStrings.tasksPlaceholder.localized,
                              rightButton: Localization.all.localized, headline: .tasks)
            + sectionsOrEmpty(for: followersModel, label: ProfileStrings.followersLabel.localized, text: ProfileStrings.followersPlaceholder.localized,
                              rightButton: Localization.all.localized, headline: .followers)
            + sectionsOrEmpty(for: followingModel, label: ProfileStrings.followingsLabel.localized, text: ProfileStrings.followingsPlaceholder.localized,
                              rightButton: Localization.all.localized, headline: .followings)
    }

    private var profileUserModel: ProfileUserView.Cell.Model?
    private var descriptionModel: TextCell.Cell.Model?
    private var taskStatistics: StatisticsView.Cell.Model?
    private var tasksModel: [TaskView.Cell.Model]?
    private var followersModel: UserFlowView.CollectionFlow?
    private var followingModel: UserFlowView.CollectionFlow?

    required init() {}

    func presentTable(_ response: Profile.Table.Response) {
        profileUserModel = makeProfileView(model: response.model, isLoading: response.isLoading)
        descriptionModel = makeTextModel(label: ProfileStrings.summaryLabel.localized,
                                         text: response.model.description ?? ProfileStrings.summaryPlaceholder.localized)

        viewController?.displayNavBar(.init(title: response.model.nickname, isEditable: response.model.isEditable))
        viewController?.displayTable(.init(sections: sections), withDiffer: false)
    }

    func presentTasks(_ response: Profile.Tasks.Response) {
        tasksModel = response.tasks.isEmpty ? nil : response.tasks.map {
            makeTasksModel(taskModel: $0, isDoneLoadingUIds: response.isLoadingDoneUIds, isLikesLoadingUids: response.isLoadingLikeUIds)
        }
        viewController?.displayTable(.init(sections: sections), withDiffer: true)
    }

    func presentStatistics(_ response: Profile.Statistics.Response) {
        let statistics = TaskModel.State.allCases.map {
            switch $0 {
            case .expired: return (number: response.statistics.expired, caption: $0.title)
            case .done: return (number: response.statistics.done, caption: $0.title)
            case .inProgress: return (number: response.statistics.inProgress, caption: $0.title)
            case .total: return (number: response.statistics.total, caption: $0.title)
            }
        }

        taskStatistics = makeStatisticsView(statistics: statistics)
        viewController?.displayTable(.init(sections: sections), withDiffer: true)
    }

    func presentUsers(_ response: Profile.Users.Response) {
        followersModel = makeUserCollectionFlow(users: response.followers.map { makeUserCell(user: $0) })
        followingModel = makeUserCollectionFlow(users: response.following.map { makeUserCell(user: $0) })

        viewController?.displayTable(.init(sections: sections), withDiffer: true)
    }

    func makeProfileView(model: ProfileModel, isLoading: Bool) -> ProfileUserView.Cell.Model {
        let isFollowing = model.isFollowing ?? false
        return .init(.init(icon: .init(url: model.photoUrl, placeholder: model.initialsImage(), style: .large),
                           nickname: model.nickname,
                           name: model.name,
                           button: model.isEditable ? nil : .Mode.makeModel(for: isFollowing ? .remove : .add, isLoading: isLoading) { [weak self] in
                               self?.viewController?.displayOnButtonFollowTap(.follow)
                           }))
    }

    private func makeTextModel(label: String, rightButton: String? = nil, text: String? = nil, headline: Profile.Headline? = nil) -> TextCell.Cell.Model {
        .init(.init(label: label.attrString, text: text?.attrString, rightButton: rightButton?.attrString).payload(headline), padding: Self.padding)
    }

    private func makeStatisticsView(statistics: [(number: Int, caption: String)]) -> StatisticsView.Cell.Model {
        .init(.init(statistics: statistics.map {
            .init(number: String($0.number).attrString, caption: $0.caption.attrString)
        }), padding: Self.padding)
    }

    private func makeTasksModel(taskModel: TaskModel, isDoneLoadingUIds: [String], isLikesLoadingUids: [String]) -> TaskView.Cell.Model {
        .makeTaskModel(from: taskModel, loadingLikesUIds: isLikesLoadingUids, loadingDoneUIds: isDoneLoadingUIds)
    }

    private func makeUserCollectionFlow(users: [UserFlowView.CollectionCell.Model]) -> UserFlowView.CollectionFlow? {
        guard !users.isEmpty else { return nil }
        let sizes = users.map(\.mainViewModel.size)
        let maxHeight = sizes.map(\.height).max() ?? .zero
        let maxWidth = sizes.map(\.width).max() ?? .zero
        return .init(items: users, itemSize: .init(width: maxWidth, height: maxHeight),
                     scrollBehaviour: .plain, isExpandSingleItemEnabled: false, backgroundColor: .clear)
    }

    private func makeUserCell(user: ProfileModel) -> UserFlowView.CollectionCell.Model {
        .init(.init(icon: .init(url: user.photoUrl, placeholder: user.initialsImage(with: .bigSquircle), style: .big),
                    nickname: user.nickname.attrString).payload(user))
    }

    private func sectionsOrEmpty(for model: CellViewAnyModel?, label: String?,
                                 text: String?, rightButton: String? = nil, withSpacer: Bool = true,
                                 headline: Profile.Headline? = nil) -> [Table.SectionViewModel] {
        sectionsOrEmpty(for: model.map { [$0] }, label: label, text: text, rightButton: rightButton, withSpacer: withSpacer, headline: headline)
    }

    private func sectionsOrEmpty(for models: [CellViewAnyModel]?, label: String?,
                                 text: String?, rightButton: String? = nil,
                                 withSpacer: Bool = true, headline: Profile.Headline? = nil) -> [Table.SectionViewModel] {
        guard let models else {
            return (label.map { .single(with: makeTextModel(label: $0, text: text)) } ?? [])
                + (withSpacer ? .single(with: SpacerView.Cell.Model(.init(), padding: .horizontal(16))) : [])
        }

        return (label.map { .single(with: makeTextModel(label: $0, rightButton: rightButton, headline: headline)) } ?? [])
            + .single(with: models)
            + (withSpacer ? .single(with: SpacerView.Cell.Model(.init(), padding: .horizontal(16))) : [])
    }
}
