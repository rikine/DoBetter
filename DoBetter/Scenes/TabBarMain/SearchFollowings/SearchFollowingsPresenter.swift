//
//  SearchFollowingsPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol SearchFollowingsPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: SearchFollowings.Table.Response)
    func presentSearchHidden(_ response: SearchFollowings.NavBar.Response)
}

class SearchFollowingsPresenter: SearchFollowingsPresentationLogic,
                                 TablePresenting,
                                 PresentingType,
                                 Initializable {

    weak var viewController: SearchFollowingsDisplayLogic?

    var sections: [Table.SectionViewModel] = []

    required init() {}

    func presentTable(_ response: SearchFollowings.Table.Response) {
        let models = response.users.map {
            makeUserModel(model: $0, isLoading: response.updatingProfilesIds.contains(where: \.self, is: $0.uid))
        } + (response.shouldShowLoading ? [.empty, .empty, .empty] : [])
        viewController?.displayTable(.init(sections: .single(with: makeInput(value: response.searchText)) + .single(with: models)), withDiffer: response.withDiffer)
    }

    func presentSearchHidden(_ response: SearchFollowings.NavBar.Response) {
        viewController?.displaySearchHidden(.init())
    }

    private func makeUserModel(model: ProfileModel, isLoading: Bool) -> SearchUserView.Cell.Model {
        let isFollowing = model.isFollowing ?? false

        return .init(.init(image: .init(url: model.photoUrl, placeholder: model.initialsImage(with: .squircle), style: .common),
                           title: model.nickname,
                           subtitle: model.description,
                           button: model.isEditable ? nil : .Mode.makeModel(for: isFollowing ? .removeSmall : .addSmall, isLoading: isLoading) { [weak viewController] in
                               viewController?.displayFollowUser(.init(user: model))
                           })
                             .payload(model))
    }

    private func makeInput(value: String?) -> InputCell.Model {
        .init(inputModel: Input.Model(placeholder: Localization.SearchUsers.filterNamePlaceholder.localized.style(.line.secondary),
                                      value: value?.style(.line),
                                      typingAttributes: TextStyle.line.attributes,
                                      isEditable: true,
                                      maxLength: 100,
                                      shouldHighlightOnFocus: true,
                                      leftIcon: .User.loupe,
                                      isPhone: false))
    }
}
