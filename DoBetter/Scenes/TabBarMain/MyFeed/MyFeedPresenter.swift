//
//  MyFeedPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol FeedPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: MyFeed.Table.Response)
    func presentFiltersCount(_ response: MyFeed.FilterCount.Response)
}

protocol FeedPresenting: FeedPresentationLogic, TablePresenting {
    var stopper: TableStopperViewModel { get }

    func onTablePresent()
}

extension FeedPresenting {
    var feedViewController: FeedDisplayLogic? { assertionCast(viewController, to: FeedDisplayLogic.self) }

    func onTablePresent() {}

    func presentTable(_ response: MyFeed.Table.Response) {
        let models = response.tasks.map {
            makeTaskModel(from: $0, loadingLikesUIds: response.loadingLikesIds, loadingDoneUIds: response.loadingDoneIds)
        } + (response.shouldShowLoading ? [.empty, .empty, .empty] : [])

        let sections: [Table.SectionViewModel] = ((models.isEmpty && response.filterName.emptyLet == nil) ? [] : .single(with: makeInput(value: response.filterName))) + .single(with: models)

        feedViewController?.displayTable(.init(sections: sections, emptyDataPlaceholder: stopper), withDiffer: response.withDiffer)
        onTablePresent()
    }

    func presentFiltersCount(_ response: MyFeed.FilterCount.Response) {
        feedViewController?.displayFiltersCount(.init(count: response.count))
    }

    private func makeTaskModel(from task: TaskModel, loadingLikesUIds: [String], loadingDoneUIds: [String]) -> TaskView.Cell.Model {
        .makeTaskModel(from: task, loadingLikesUIds: loadingLikesUIds, loadingDoneUIds: loadingDoneUIds)
    }

    private func makeInput(value: String?) -> InputCell.Model {
        .init(inputModel: Input.Model(placeholder: Localization.MyFeed.searchTaskPlaceholder.localized.style(.line.secondary),
                                      value: value?.style(.line),
                                      typingAttributes: TextStyle.line.attributes,
                                      isEditable: true,
                                      maxLength: 100,
                                      shouldHighlightOnFocus: true,
                                      leftIcon: .User.loupe,
                                      isPhone: false))
    }
}

protocol MyFeedPresentationLogic: FeedPresentationLogic { }

class MyFeedPresenter: MyFeedPresentationLogic, FeedPresenting, Initializable {
    weak var viewController: MyFeedDisplayLogic?

    var sections: [Table.SectionViewModel] = []

    var stopper: TableStopperViewModel { .ownTasksPlaceholder }

    required init() {}
}
