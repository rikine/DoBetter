//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

protocol TableBusinessLogic: CommonBusinessLogic {
    func didSelectRow(_ request: Table.Selection.Request)
}

protocol TableInteracting: TableBusinessLogic {}
