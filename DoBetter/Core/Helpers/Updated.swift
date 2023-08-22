//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

///
/// Before:
/// func width(_ newValue) -> Self {
///     var new = self
///     new.width = width
///     return new
/// }
///
/// Now:
/// func width(_ newValue) -> Self { updated(\.width, newValue) }
///
public protocol Updatable {
    func updated<T>(_ keyPaths: WritableKeyPath<Self, T>..., with newValue: T) -> Self
    func updated(_ updateClosure: (inout Self) -> Void) -> Self
}

public extension Updatable {
    func updated<T>(_ keyPaths: WritableKeyPath<Self, T>..., with newValue: T) -> Self {
        var new = self
        keyPaths.forEach { keyPath in
            new[keyPath: keyPath] = newValue
        }
        return new
    }

    func updated(_ updateClosure: (inout Self) -> Void) -> Self {
        var new = self
        updateClosure(&new)
        return new
    }
}
