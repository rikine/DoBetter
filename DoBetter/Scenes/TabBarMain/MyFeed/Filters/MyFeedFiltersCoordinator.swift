//
//  MyFeedFiltersCoordinator.swift
//  DoBetter
//
//  Created by Никита Шестаков on 09.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation
import UIKit
import SPStorkController

typealias MyFeedFiltersScene = VIPScene<MyFeedFiltersViewController, MyFeedFiltersInteractor, MyFeedFiltersPresenter>

class MyFeedFiltersCoordinator: ChainedDrawerCoordinator<MyFeedFiltersScene>, TableDrawerCoordinating {
    var onResult: ((MyFeed.Filters) -> Void)?
    var model: MyFeed.Filters?

    init(on: UIViewController, model: MyFeed.Filters) {
        super.init(onPresenting: on, withNavigation: false, root: MyFeedFiltersScene(interactor: .init(model: model)))
        root.interactor.coordinator = self
    }

    func updateHeight() {
        tableDrawerHeight.let(changeDrawerHeight)
    }

    override func modifyTransitionDelegate(_ transitionDelegate: SPStorkTransitioningDelegate) {
        super.modifyTransitionDelegate(transitionDelegate)
        transitionDelegate.customHeight = 619
    }

    override func rootVCDidDismiss() {
        super.rootVCDidDismiss()
        if let model { onResult?(model) }
    }

    @discardableResult
    func onResult(_ action: @escaping (MyFeed.Filters) -> Void) -> Self {
        onResult = action
        return self
    }
}
