//
// Created by Никита Шестаков on 05.03.2023.
//

import Foundation

public protocol Identifier: RawRepresentable, Hashable, CustomStringConvertible {}

extension Identifier {
    public var description: String { .init(describing: rawValue) }
}

public struct PersonID: Identifier, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
