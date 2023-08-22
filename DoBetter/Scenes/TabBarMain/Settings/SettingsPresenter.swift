//
//  SettingsPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 16.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol SettingsPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: Settings.Table.Response)
    func presentBioAuthAlert(_ response: BioAuth.Suggest.Response)
}

class SettingsPresenter: SettingsPresentationLogic,
                         TablePresenting,
                         PresentingType,
                         Initializable {

    weak var viewController: SettingsDisplayLogic?

    var sections: [Table.SectionViewModel] = []

    required init() {}

    func presentTable(_ response: Settings.Table.Response) {
        let bioAuthModel = makeSetting(.bioAuth, isEnabled: response.isFaceIDEnabled)
        let secureModel = makeSetting(.secure, isEnabled: response.isSecureProfileEnabled)

        viewController?.displayTable(.init(sections: .single(with: bioAuthModel, secureModel)), withDiffer: true)
    }

    func presentBioAuthAlert(_ response: BioAuth.Suggest.Response) {
        viewController?.displayBioAuthAlert(.init())
    }

    private func makeSetting(_ payload: Settings.Setting, isEnabled: Bool) -> SettingView.Cell.Model {
        .init(.init(title: payload.title.attrString, isSwitcherOn: isEnabled).payload(payload),
              padding: .horizontal(16) + .vertical(8))
    }
}
