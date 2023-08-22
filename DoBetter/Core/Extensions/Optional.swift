//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

public extension Optional {
    /*
    Same as `map` but with @discardableResult
    */
    @discardableResult
    func `let`<T>(_ block: (Wrapped) -> T) -> T? {
        guard let some = self else { return nil }
        return block(some)
    }

    func also(_ block: (Wrapped) -> Void) -> Wrapped? {
        if let some = self {
            block(some)
        }
        return self
    }
}
