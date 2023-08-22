//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

public enum Either<L, R> {
    case left(L)
    case right(R)

    public var left: L? {
        switch self {
        case let .left(value):
            return value
        case .right:
            return nil
        }
    }

    public var right: R? {
        switch self {
        case .left:
            return nil
        case let .right(value):
            return value
        }
    }

    public var isLeft: Bool {
        switch self {
        case .left:
            return true
        case .right:
            return false
        }
    }

    public var isRight: Bool {
        switch self {
        case .right:
            return true
        case .left:
            return false
        }
    }

    /// Transforms the left value if the `Either` is a `.left`.
    public func mapLeft<M>(_ transform: (L) throws -> M) rethrows -> Either<M, R> {
        return try biMap(left: transform, right: { $0 })
    }

    /// Transforms the right value if the `Either` is a `.right`.
    public func mapRight<S>(_ transform: (R) throws -> S) rethrows -> Either<L, S> {
        return try biMap(left: { $0 }, right: transform)
    }

    /// Transforms either the left or right value, dependent on which the `Either` is.
    public func biMap<M, S>(left leftTransform: (L) throws -> M, right rightTransform: (R) throws -> S) rethrows -> Either<M, S> {
        switch self {
        case let .left(value):
            return try .left(leftTransform(value))
        case let .right(value):
            return try .right(rightTransform(value))
        }
    }

    public func flatMapLeft<M>(_ transform: (L) throws -> Either<M, R>) rethrows -> Either<M, R> {
        return try biFlatMap(left: transform, right: Either<M, R>.right)
    }

    public func flatMapRight<S>(_ transform: (R) throws -> Either<L, S>) rethrows -> Either<L, S> {
        return try biFlatMap(left: Either<L, S>.left, right: transform)
    }

    public func biFlatMap<M, S>(left: (L) throws -> Either<M, S>, right: (R) throws -> Either<M, S>) rethrows -> Either<M, S> {
        switch self {
        case let .left(value):
            return try left(value)
        case let .right(value):
            return try right(value)
        }
    }

    public func zipLeft<M>(with second: Either<M, R>) -> Either<(L, M), R> {
        switch (self, second) {
        case let (.left(first), .left(second)):
            return .left((first, second))
        case let (.right(value), _):
            return .right(value)
        case let (_, .right(value)):
            return .right(value)
        }
    }

    public func zipLeft<M, N>(with second: Either<M, R>, _ third: Either<N, R>) -> Either<(L, M, N), R> {
        switch (self, second, third) {
        case let (.left(first), .left(second), .left(third)):
            return .left((first, second, third))
        case let (.right(value), _, _):
            return .right(value)
        case let (_, .right(value), _):
            return .right(value)
        case let (_, _, .right(value)):
            return .right(value)
        }
    }

    public func zipLeft<M, N, O>(with second: Either<M, R>, _ third: Either<N, R>, _ fourth: Either<O, R>) -> Either<(L, M, N, O), R> {
        switch (self, second, third, fourth) {
        case let (.left(first), .left(second), .left(third), .left(fourth)):
            return .left((first, second, third, fourth))
        case let (.right(value), _, _, _):
            return .right(value)
        case let (_, .right(value), _, _):
            return .right(value)
        case let (_, _, .right(value), _):
            return .right(value)
        case let (_, _, _, .right(value)):
            return .right(value)
        }
    }

    public func zipLeft<M, N, O, P>(with second: Either<M, R>, _ third: Either<N, R>, _ fourth: Either<O, R>, _ fifth: Either<P, R>) -> Either<(L, M, N, O, P), R> {
        switch (self, second, third, fourth, fifth) {
        case let (.left(first), .left(second), .left(third), .left(fourth), .left(fifth)):
            return .left((first, second, third, fourth, fifth))
        case let (.right(value), _, _, _, _):
            return .right(value)
        case let (_, .right(value), _, _, _):
            return .right(value)
        case let (_, _, .right(value), _, _):
            return .right(value)
        case let (_, _, _, .right(value), _):
            return .right(value)
        case let (_, _, _, _, .right(value)):
            return .right(value)
        }
    }

    public func zipRight<S>(with second: Either<L, S>) -> Either<L, (R, S)> {
        switch (self, second) {
        case let (.right(first), .right(second)):
            return .right((first, second))
        case let (.left(value), _):
            return .left(value)
        case let (_, .left(value)):
            return .left(value)
        }
    }

    public func zipRight<S, T>(with second: Either<L, S>, _ third: Either<L, T>) -> Either<L, (R, S, T)> {
        switch (self, second, third) {
        case let (.right(first), .right(second), .right(third)):
            return .right((first, second, third))
        case let (.left(value), _, _):
            return .left(value)
        case let (_, .left(value), _):
            return .left(value)
        case let (_, _, .left(value)):
            return .left(value)
        }
    }

    public func zipRight<S, T, U>(with second: Either<L, S>, _ third: Either<L, T>, _ fourth: Either<L, U>) -> Either<L, (R, S, T, U)> {
        switch (self, second, third, fourth) {
        case let (.right(first), .right(second), .right(third), .right(fourth)):
            return .right((first, second, third, fourth))
        case let (.left(value), _, _, _):
            return .left(value)
        case let (_, .left(value), _, _):
            return .left(value)
        case let (_, _, .left(value), _):
            return .left(value)
        case let (_, _, _, .left(value)):
            return .left(value)
        }
    }

    public func zipRight<S, T, U, V>(with second: Either<L, S>, _ third: Either<L, T>, _ fourth: Either<L, U>, _ fifth: Either<L, V>) -> Either<L, (R, S, T, U, V)> {
        switch (self, second, third, fourth, fifth) {
        case let (.right(first), .right(second), .right(third), .right(fourth), .right(fifth)):
            return .right((first, second, third, fourth, fifth))
        case let (.left(value), _, _, _, _):
            return .left(value)
        case let (_, .left(value), _, _, _):
            return .left(value)
        case let (_, _, .left(value), _, _):
            return .left(value)
        case let (_, _, _, .left(value), _):
            return .left(value)
        case let (_, _, _, _, .left(value)):
            return .left(value)
        }
    }
}

public extension Either where L == R {
    var consolidated: L {
        switch self {
        case let .left(value):
            return value
        case let .right(value):
            return value
        }
    }
}

extension Either: Decodable where L: Decodable, R: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try (try? container.decode(R.self)).map(Either.right)
            ?? .left(container.decode(L.self))
    }
}

extension Either: Encodable where L: Encodable, R: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .left(left):
            try container.encode(left)
        case let .right(right):
            try container.encode(right)
        }
    }
}

extension Either: Equatable where L: Equatable, R: Equatable {}
