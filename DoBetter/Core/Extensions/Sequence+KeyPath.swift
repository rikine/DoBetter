//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

public extension Sequence {

    func compactMap<T>(_ keyPath: KeyPath<Self.Element, T?>) -> [T] {
        compactMap { $0[keyPath: keyPath] }
    }

    func compactMap<T>(_ type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }

    func compactMap<T, U>(_ type: T.Type, _ keyPath: KeyPath<T, U>) -> [U] {
        compactMap {
            if let casted = $0 as? T {
                return casted[keyPath: keyPath]
            } else {
                return nil
            }
        }
    }

    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, descending: Bool = false) -> [Element] {
        sorted { a, b in
            (a[keyPath: keyPath] < b[keyPath: keyPath]) != descending
        }
    }

    func contains<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, is element: T) -> Bool {
        contains { $0[keyPath: keyPath] == element }
    }

    func contains<T: Equatable, U: Equatable>(where keyPath: KeyPath<Self.Element, T>,
                                              _ keyPath2: KeyPath<Self.Element, U>,
                                              is element: T,
                                              _ element2: U) -> Bool {
        contains { $0[keyPath: keyPath] == element && $0[keyPath: keyPath2] == element2 }
    }

    func contains<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isNot element: T) -> Bool {
        contains { $0[keyPath: keyPath] != element }
    }

    func contains<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isIn elements: [T]) -> Bool {
        contains { elements.contains($0[keyPath: keyPath]) }
    }

    func contains<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isNotIn elements: [T]) -> Bool {
        contains { !elements.contains($0[keyPath: keyPath]) }
    }

    func contains<T, U>(where keyPath: KeyPath<Self.Element, T>, isType: U.Type) -> Bool {
        contains { $0[keyPath: keyPath] is U }
    }

    func contains<T>(_ type: T.Type) -> Bool {
        contains { $0 is T }
    }

    func filter<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, is element: T) -> [Self.Element] {
        filter { $0[keyPath: keyPath] == element }
    }

    func filter<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isIn elements: [T]) -> [Self.Element] {
        filter { elements.contains($0[keyPath: keyPath]) }
    }

    func filter<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isNotIn elements: [T]) -> [Self.Element] {
        filter { !elements.contains($0[keyPath: keyPath]) }
    }

    func filter<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isNot element: T) -> [Self.Element] {
        filter { $0[keyPath: keyPath] != element }
    }

    func filter<T: Equatable>(where keyPath: KeyPath<Self.Element, [T]>, contains element: T) -> [Self.Element] {
        filter { $0[keyPath: keyPath].contains(element) }
    }

    func filter<T: Comparable>(where keyPath: KeyPath<Self.Element, T>, biggerThan element: T) -> [Self.Element] {
        filter { $0[keyPath: keyPath] > element }
    }

    func filter<T: Comparable>(where keyPath: KeyPath<Self.Element, T>, lessThan element: T) -> [Self.Element] {
        filter { $0[keyPath: keyPath] < element }
    }

    func filter<T: Comparable>(where keyPath: KeyPath<Self.Element, T>, clampedIn range: ClosedRange<T>) -> [Self.Element] {
        filter { range.lowerBound <= $0[keyPath: keyPath] && $0[keyPath: keyPath] <= range.upperBound }
    }

    func filter(in list: [Element]) -> [Self.Element] where Element: Equatable {
        filter { list.contains($0) }
    }

    func filter(notIn list: [Element]) -> [Self.Element] where Element: Equatable {
        filter { !list.contains($0) }
    }

    /// Returns true if there exist at least one element in the sequence which is true.
    /// If all elements are false returns false
    func anySatisfy(_ keyPath: KeyPath<Self.Element, Bool>) -> Bool {
        contains(where: keyPath, is: true)
    }

    func allSatisfy(_ keyPath: KeyPath<Self.Element, Bool>) -> Bool {
        allSatisfy { $0[keyPath: keyPath] }
    }

    func allSatisfy<T: Equatable>(_ keyPath: KeyPath<Self.Element, T>, to element: T) -> Bool {
        allSatisfy { $0[keyPath: keyPath] == element }
    }

    func first<T, K>(where keyPath: KeyPath<Self.Element, T>, isTypeOf: K.Type) -> Self.Element? {
        first { $0[keyPath: keyPath] is K }
    }

    func first<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, is element: T) -> Self.Element? {
        first { $0[keyPath: keyPath] == element }
    }

    func first<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isOptional element: T?) -> Self.Element? {
        guard let element = element else { return nil }
        return first(where: keyPath, is: element)
    }

    func first<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, isNot element: T) -> Self.Element? {
        first { $0[keyPath: keyPath] != element }
    }

    func first(_ keyPath: KeyPath<Self.Element, Bool>) -> Self.Element? {
        first(where: keyPath, is: true)
    }

    func first<T: Comparable>(where keyPath: KeyPath<Self.Element, T>, biggerThan element: T) -> Self.Element? {
        first { $0[keyPath: keyPath] > element }
    }

    func first<T>(_ type: T.Type) -> T? {
        for item in self {
            if let item = item as? T { return item }
        }
        return nil
    }

    func flatten<T>() -> [T] where Element == T? { compactMap { $0 } }

    func flatten<T>() -> [T] where Element == [T] { flatMap { $0 } }

    func zip<T: Sequence>(with other: T) -> Zip2Sequence<Self, T> { Swift.zip(self, other) }
}

extension RangeReplaceableCollection {
    @discardableResult
    mutating func removeFirst<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, is element: T) -> Self.Element? {
        guard let index = firstIndex(where: { $0[keyPath: keyPath] == element }) else { return nil }
        return remove(at: index)
    }
}
