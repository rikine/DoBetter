//
//  HiddenProfileSearchPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol HiddenProfileSearchPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: HiddenProfileSearch.Table.Response)
}

class HiddenProfileSearchPresenter: HiddenProfileSearchPresentationLogic,
                                    TablePresenting,
                                    PresentingType,
                                    Initializable {

    weak var viewController: HiddenProfileSearchDisplayLogic?

    var sections: [Table.SectionViewModel] {
        .single(with: SignModelPresenter.makeInputCell(inputID: .nickname, placeholder: "Введите логин"))
    }

    required init() {}

    func presentTable(_ response: HiddenProfileSearch.Table.Response) {
        viewController?.displayTable(.init(sections: sections))
    }
}
