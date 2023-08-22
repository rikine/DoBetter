//
//  PhoneCodeEnterCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 11.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation
import UIKit
import SPStorkController

typealias PhoneCodeEnterScene = VIPScene<PhoneCodeEnterViewController, PhoneCodeEnterInteractor, PhoneCodeEnterPresenter>

class PhoneCodeEnterCoordinator: ChainedDrawerCoordinator<PhoneCodeEnterScene>, TableDrawerCoordinating {
    private var withSuccess: Bool?
    private var onResult: ((Bool) -> Void)?

    init(on: UIViewController, phone: String, nickname: String? = nil) {
        super.init(onPresenting: on,
                   withNavigation: false,
                   root: PhoneCodeEnterScene(interactor: .init(phone: phone, nickname: nickname)))
        root.interactor.coordinator = self
    }

    override func modifyTransitionDelegate(_ transitionDelegate: SPStorkTransitioningDelegate) {
        super.modifyTransitionDelegate(transitionDelegate)
        transitionDelegate.customHeight = 300
    }

    func changeHeight() {
        changeDrawerHeight(tableDrawerHeight ?? 0)
    }

    func stop(withSuccess: Bool) {
        self.withSuccess = withSuccess
        super.stop()
    }

    @discardableResult
    func onResult(_ onResult: @escaping (Bool) -> Void) -> Self {
        self.onResult = onResult
        return self
    }

    override func rootVCDidDismiss() {
        super.rootVCDidDismiss()
        withSuccess.let { onResult?($0) }
    }
}
