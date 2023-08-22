//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

/// Serves as weak collection, reaps on adding new elements
public class WeakArray<Element> {
    private var underlyingArray = [WeakBox<Element>]()

    public init() {}

    // TODO proxy Array methods
    public func append(_ newElement: Element) {
        reap()
        underlyingArray.append(^^newElement)
    }

    public func append(contentOf newElements: [Element]) {
        reap()
        underlyingArray.append(contentsOf: newElements.map(^^))
    }

    public func remove(_ element: Element) {
        guard let element = element as? AnyObject else { return }
        underlyingArray.removeAll {
            guard let kek = $0.boxed as? AnyObject else { return false }
            return kek === element
        }
    }

    public func removeAll() {
        underlyingArray.removeAll()
    }

    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try iterate().forEach(body)
    }

    public func iterate() -> [Element] { underlyingArray.compactMap(\.boxed) }

    /// Reaps nil elements
    public func reap() { underlyingArray.removeAll(where: \.isEmpty) }

    static func +=<T>(lhs: inout WeakArray<T>, rhs: T) { lhs.append(rhs) }

    @discardableResult
    public func appendIfNotContains(_ newElement: Element, comparator: (Element, Element) -> Bool) -> Bool {
        reap()
        if !underlyingArray.contains(where: { box in
            guard let boxed = box.boxed else { return false }
            return comparator(boxed, newElement)
        }) {
            underlyingArray.append(^^newElement)
            return true
        } else {
            return false
        }
    }
}

extension WeakArray where Element: Equatable {

    @discardableResult
    public func appendIfNotContains(_ newElement: Element) -> Bool {
        appendIfNotContains(newElement, comparator: ==)
    }
}
