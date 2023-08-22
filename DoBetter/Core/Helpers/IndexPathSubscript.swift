//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation

public protocol IndexPathSubscript<UnderlyingElement> {
    associatedtype UnderlyingElement
    static var underlyingArray: WritableKeyPath<Self, [UnderlyingElement]> { get }
}

public extension IndexPathSubscript {

    var underlyingArray: [UnderlyingElement] {
        get { self[keyPath: Self.underlyingArray] }
        set { self[keyPath: Self.underlyingArray] = newValue }
    }
}

public extension Array where Element: IndexPathSubscript {

    subscript(_ indexPath: IndexPath) -> Element.UnderlyingElement {
        get { self[indexPath.section].underlyingArray[indexPath.row] }
        set { self[indexPath.section].underlyingArray[indexPath.row] = newValue }
    }

    subscript(optional indexPath: IndexPath) -> Element.UnderlyingElement? {
        guard indexPath.section < self.count,
              indexPath.row < self[indexPath.section].underlyingArray.count else { return nil }
        return self[indexPath.section].underlyingArray[indexPath.row]
    }

    func firstIndexPath<T>(of type: T.Type) -> IndexPath? {

        guard let section = firstIndex(where: { $0.underlyingArray.contains(T.self) }),
              let row = self[section].underlyingArray.firstIndex(where: { $0 is T }) else { return nil }

        return IndexPath(row: row, section: section)
    }

    func firstIndexPath<T: Equatable>(of item: T) -> IndexPath? {
        guard let section = firstIndex(where: { $0.underlyingArray.contains(where: { ($0 as? T) == item }) }),
              let row = self[section].underlyingArray.firstIndex(where: { ($0 as? T) == item }) else { return nil }

        return IndexPath(row: row, section: section)
    }

    func firstIndexPath<T>(_ predicate: (T) -> Bool) -> IndexPath? {
        for (sectionIndex, section) in enumerated() {
            for (row, cell) in section.underlyingArray.enumerated() {
                if (cell as? T).map(predicate) == true {
                    return IndexPath(row: row, section: sectionIndex)
                }
            }
        }
        return nil
    }
}
