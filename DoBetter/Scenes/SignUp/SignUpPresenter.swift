//
//  SignUpPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 07.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol SignUpPresentationLogic: TablePresentationLogic, BioAuthPresentationLogic {
    func presentTable(_ response: SignUp.Table.Response)
}

class SignUpPresenter: SignUpPresentationLogic,
                       TablePresenting,
                       PresentingType,
                       Initializable,
                       BioAuthPresenting {

    private typealias ModelPresenter = SignModelPresenter

    weak var viewController: SignUpDisplayLogic?

    var sections: [Table.SectionViewModel] {
        .single(with: (screenType?.inputs.map { makeInputCell($0) } ?? []) + [makeButtonBar()])
    }

    private var screenType: SignUp.ScreenType?

    required init() {}

    private func makeInputCell(_ input: SignIn.Input) -> InputCell.Model {
        ModelPresenter.makeInputCell(inputID: input.inputID,
                                     placeholder: input.placeholder,
                                     leftIcon: input.leftIcon,
                                     isSecure: input.isSecure,
                                     isPhone: input == .phone)
    }

    private func makeButtonBar() -> ButtonBarStack.Cell.Model {
        .init(.init(buttons: screenType?.buttons.map { makeButton(for: $0) } ?? []),
              backgroundColor: .clear, padding: .horizontal(16))
    }

    private func makeButton(for button: SignUp.Button) -> RoundCornersButton.Model {
        .init(text: button.title, style: button.style) { [weak viewController] in
            viewController?.displayOnButtonTap(.init(button: button))
        }
    }

    func presentTable(_ response: SignUp.Table.Response) {
        screenType = response.screenType
        viewController?.displayTable(.init(sections: sections), withDiffer: true)
    }
}

extension CommonInputID {
    static let nickname = CommonInputID(rawValue: "Nickname")
    static let passwordReenter = CommonInputID(rawValue: "PasswordReenter")
}
