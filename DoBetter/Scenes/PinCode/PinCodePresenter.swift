//
//  PinCodePresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol PinCodePresentationLogic: TablePresentationLogic {
    func presentAlert(_ response: PinCode.Alert.Response)
    func presentPlaceholder(_ response: PinCode.Placeholder.Response)
}

class PinCodePresenter: PinCodePresentationLogic,
                        TablePresenting,
                        PresentingType,
                        Initializable {

    weak var viewController: PinCodeDisplayLogic?

    var sections: [Table.SectionViewModel] { []}

    required init() {}

    func presentAlert(_ response: PinCode.Alert.Response) {
        viewController?.displayAlert(.init(alert: response.alert))
    }

    func presentPlaceholder(_ response: PinCode.Placeholder.Response) {
        viewController?.displayPlaceholder(.init())
    }
}
