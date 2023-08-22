//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation

private let userInfoKey = CodingUserInfoKey(rawValue: "itmo.dobetter")!

private struct _CodingKey: CodingKey {

    let key: String

    var stringValue: String { key }

    var intValue: Int? { nil }

    init(stringValue: String) { key = stringValue }

    init?(intValue: Int) { nil }
}

private struct DecodableWrapper<T: Decodable>: Decodable {

    let wrapped: T

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: _CodingKey.self)

        guard let key = decoder.userInfo[userInfoKey] as? String else {
            assertionFailure("The top-level key is not set")
            let context = DecodingError.Context(codingPath: [], debugDescription: "The top-level key is not set")
            throw DecodingError.dataCorrupted(context)
        }

        wrapped = try container.decode(T.self, forKey: _CodingKey(stringValue: key))
    }
}

extension JSONMDecoder {

    /// Assume we have the following JSON:
    ///
    /// ```
    /// {
    ///    "ObjectType": {
    ///        "key": "value"
    ///    }
    /// }
    /// ```
    ///
    /// By invoking this methods as `decoder.decodeWrappedObject(type: ObjectType.self)`
    /// we can get the decodable.
    ///
    /// - Parameters:
    ///   - type: The type that is encoded in JSON
    ///           with a single key of the same name as the type.
    ///   - topLevelKey: The top-level key that wraps a value of type `T`.
    ///                  If `nil`, uses the type name. Defaults to `nil`
    ///   - data: The data to decode from.
    /// - Returns: A value of the requested type.
    /// - Throws: An error if any value throws an error during decoding.
    internal func decodeWrappedObject<T: Decodable>(type: T.Type,
                                                    topLevelKey: String? = nil,
                                                    from data: Data) throws -> T {

        let typeName = topLevelKey ?? String(describing: type)

        var errorWithoutTopLevelKey: Error?

        if topLevelKey == nil {
            do {
                if T.self is CustomDecodable.Type {
                    return try decode(CustomDecodableWrapper<T>.self, from: data).wrapped
                }
                return try decode(T.self, from: data)
            } catch {
                print(error)
                errorWithoutTopLevelKey = error
                // Continue, try to decode as a wrapped object
            }
        }

        // This value will be extracted by the `DecodableWrapper`.
        userInfo[userInfoKey] = typeName

        do {

            let wrapper = try decode(DecodableWrapper<T>.self, from: data)
            return wrapper.wrapped

        } catch DecodingError.typeMismatch {

            let wrapper = try decode(DecodableWrapper<[T]>.self, from: data)

            if let value = wrapper.wrapped.first {
                return value
            } else {

                let context = DecodingError
                        .Context(codingPath: [_CodingKey(stringValue: typeName)],
                                 debugDescription: "The value for key \(typeName) contains an empty array ")

                if let errorWithoutTopLevelKey = errorWithoutTopLevelKey {
                    throw errorWithoutTopLevelKey
                }
                throw DecodingError.valueNotFound(T.self, context)
            }

        } catch {
            if let errorWithoutTopLevelKey = errorWithoutTopLevelKey {
                throw errorWithoutTopLevelKey
            }
            throw error
        }
    }
}

// You can conform built-in type to CustomDecodable to provide custom initializer if synthesized one is not satisfying
// Look at GroupedNews.swift for example

public protocol CustomDecodable: Decodable {
    init(customInitFrom decoder: Decoder) throws
}

struct CustomDecodableWrapper<T: Decodable>: Decodable {
    let wrapped: T

    init(from decoder: Decoder) throws {
        if let customDecodableType = T.self as? CustomDecodable.Type,
           let value = try customDecodableType.init(customInitFrom: decoder) as? T {
            wrapped = value
        } else {
            wrapped = try T(from: decoder)
        }
    }
}
