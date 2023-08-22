//
//  HiddenProfileSearchCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation
import SPStorkController

typealias HiddenProfileSearchScene = VIPScene<HiddenProfileSearchViewController, HiddenProfileSearchInteractor, HiddenProfileSearchPresenter>

class HiddenProfileSearchCoordinator: ChainedDrawerCoordinator<HiddenProfileSearchScene>, TableDrawerCoordinating {
    private var withSuccess: ProfileModel?
    private var onResult: ((ProfileModel) -> Void)?

    init(on: MainNavController) {
        super.init(onPresenting: on, withNavigation: false, root: HiddenProfileSearchScene())
        root.interactor.coordinator = self
    }

    override func modifyTransitionDelegate(_ transitionDelegate: SPStorkTransitioningDelegate) {
        super.modifyTransitionDelegate(transitionDelegate)
        transitionDelegate.customHeight = 300
    }

    func changeHeight() {
        changeDrawerHeight(tableDrawerHeight ?? 0)
    }

    func stop(withSuccess: ProfileModel) {
        self.withSuccess = withSuccess
        super.stop()
    }

    @discardableResult
    func onResult(_ onResult: @escaping (ProfileModel) -> Void) -> Self {
        self.onResult = onResult
        return self
    }

    override func rootVCDidDismiss() {
        super.rootVCDidDismiss()
        withSuccess.let { onResult?($0) }
    }
}
