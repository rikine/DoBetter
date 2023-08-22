//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

struct Animation {
    struct Duration {
        static let quickFade: TimeInterval = 0.15
        static let `default`: TimeInterval = 0.2
        static let skeleton: TimeInterval = 0.25
        static let defaultKeyboard: TimeInterval = 0.3
        static let transitionCrossDissolve: TimeInterval = 0.3
        static let menu: TimeInterval = 0.4
        static let valueChanged: TimeInterval = 0.4
        static let actionSheet: TimeInterval = 0.3
        static let chatTyping: TimeInterval = 3.0
    }
}