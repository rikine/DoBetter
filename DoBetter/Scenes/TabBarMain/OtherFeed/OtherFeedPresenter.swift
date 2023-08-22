//
//  OtherFeedPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol OtherFeedPresentationLogic: FeedPresentationLogic {}

class OtherFeedPresenter: OtherFeedPresentationLogic, FeedPresenting {

    weak var viewController: OtherFeedDisplayLogic?
    
    var sections: [Table.SectionViewModel] = []

    let stopper: TableStopperViewModel
    let isCurrent: Bool

    required init(isCurrent: Bool) {
        self.isCurrent = isCurrent
        stopper = isCurrent ? .otherTasksPlaceholder : .otherTasksPlaceholderNotCurrent
    }

    func onTablePresent() {
        viewController?.displayNavBar(.init(isCurrent: isCurrent))
    }
}
