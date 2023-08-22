//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

public extension Collection {
    subscript(optional index: Index) -> Iterator.Element? {
        indices.contains(index) ? self[index] : nil
    }
}
