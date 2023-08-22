//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation

struct TabBarScreenOption {
    static let defaultScreenIdentifier = Identifier.myFeed

    enum Identifier: Codable, Equatable, CaseIterable {
        case myFeed, otherFeed

        var tabIndex: Int {
            Self.allCases.firstIndex(of: self) ?? 0
        }

        var icon: IconModel? {
            switch self {
            default:
                return nil
            }
        }
    }

    let identifier: Identifier

    var title: String {
        switch identifier {
        case .myFeed: return "My feed"
        case .otherFeed: return "Feed"
        }
    }

    init(identifier: Identifier) {
        self.identifier = identifier
    }
}

extension TabBarScreenOption: Equatable {
    static func ==(lhs: TabBarScreenOption, rhs: TabBarScreenOption) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
