//
//  PhoneCodeEnterPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 11.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol PhoneCodeEnterPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: PhoneCodeEnter.Table.Response)
    func presentTimer(_ response: PhoneCodeEnter.Timer.Response)
}

class PhoneCodeEnterPresenter: PhoneCodeEnterPresentationLogic,
                               TablePresenting,
                               PresentingType,
                               Initializable {

    weak var viewController: PhoneCodeEnterDisplayLogic?

    var sections: [Table.SectionViewModel] {
        .single(with: SignModelPresenter.makeInputCell(inputID: .code, placeholder: Localization.PhoneCode.placeholder.localized))
    }

    required init() {}

    func presentTable(_ response: PhoneCodeEnter.Table.Response) {
        viewController?.displayTable(.init(sections: sections))
    }

    func presentTimer(_ response: PhoneCodeEnter.Timer.Response) {
        viewController?.displayTimer(.init(state: response.state))
    }
}

extension CommonInputID {
    static let code = CommonInputID(rawValue: "Code")
}
