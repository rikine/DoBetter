//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

public final class ThreadSafe<T> {

    private lazy var _syncQueue = DispatchQueue(label: "ru.vision-invest.app.ThreadSafe.\(ObjectIdentifier(self))",
                                                attributes: .concurrent)

    private var _value: T

    public init(_ value: T) {
        _value = value
    }

    public var value: T {
        return _syncQueue.sync { return _value }
    }

    public func atomically(execute: (inout T) -> Void) {
        _syncQueue.sync(flags: .barrier) {
            execute(&_value)
        }
    }
}

@propertyWrapper
public struct ThreadSafeProperty<T> {
    private var value: ThreadSafe<T>
    public var wrappedValue: T {
        get {
            value.value
        }
        set {
            value.atomically {
                $0 = newValue
            }
        }
    }

    public init(wrappedValue value: T) {
        self.value = ThreadSafe<T>(value)
    }
}
