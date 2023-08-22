//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation
import UIKit

enum RootNavigationTabBar {

    // MARK: Use cases

    enum TabBarScreen {

        struct Request {
            init(identifier: TabBarScreenOption.Identifier? = nil) {
                self.identifier = identifier
            }
            let identifier: TabBarScreenOption.Identifier?
        }

        struct Response {
            let identifier: TabBarScreenOption.Identifier
        }

        struct ViewModel {
            let tabIndex: Int
        }
    }
}
