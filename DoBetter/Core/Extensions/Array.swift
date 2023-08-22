//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

public extension Array {
    func copied() -> [Element]? where Element: NSCopying {
        map { ($0 as NSCopying).copy() } as? [Element]
    }

    mutating func remove(_ view: Element) where Element: UIView {
        guard let index = firstIndex(where: { $0 === view }) else { return }
        remove(at: index)
    }

    func sum() -> Element where Element: Numeric {
        self.reduce(0, +)
    }
}
