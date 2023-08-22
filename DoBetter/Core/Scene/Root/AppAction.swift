//
// Created by Никита Шестаков on 04.03.2023.
//

import Foundation

public protocol AppAction {}

public enum AppActionKind: String, Decodable {
    case local      = "LOCAL"
    case external   = "EXTERNAL"
}

public protocol AppActionSource {
    var kind: AppActionKind? { get }
    var section: LocalAction? { get }
    var externalURL: URL? { get }
}

public struct AppExternalAction: AppAction, Equatable {
    public var url: URL
}

public struct AppLocalAction: AppAction, Equatable {
    public var section: LocalAction

    public init(section: LocalAction) {
        self.section = section
    }
}

extension AppActionSource {
    public var action: AppAction? {
        guard let kind = kind else { return nil }
        switch kind {
        case .local:
            guard let section = section else { break }
            return AppLocalAction(section: section)
        case .external:
            guard let url = externalURL else { break }
            return AppExternalAction(url: url)
        }
        return nil
    }
    public var kind: AppActionKind? { return nil }
    public var section: LocalAction? { return nil }
    public var externalURL: URL? { return nil }
}
