//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation

public struct Decoding {

    /// Decodes a top-level value of the given type from the data received from the server.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from
    ///           the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public static func decode<T: Decodable>(_ type: T.Type,
                                            topLevelKey: String? = nil,
                                            from data: Data) throws -> T {

        let decoder = JSONMDecoder()
        decoder.dateDecodingStrategy = .custom(decodeDate(from:))

        return try decoder.decodeWrappedObject(type: type,
                                               topLevelKey: topLevelKey,
                                               from: data)
    }

    static let dateTimeFormatterWithTimeZone = server("yyyy-MM-dd'T'HH:mm:ssZZZZZ")

    private static func dateFromISO8601String(_ str: String) -> Date? {
        var string = str
        if let range = string.range(of: "1900") {
            string.replaceSubrange(range, with: "1970")
        }
        return dateTimeFormatterWithTimeZone.date(from: string)
    }

    private static func server(_ dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter(dateFormat)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    internal static func decodeDate(from decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()

        do {
            let string = try container.decode(String.self)

            if let date = dateFromISO8601String(string) {
                return date
            } else {
                let context = DecodingError.Context(codingPath: container.codingPath,
                                                    debugDescription: "Expected date string to be ISO8601-formatted.")
                throw DecodingError.dataCorrupted(context)
            }
        } catch DecodingError.typeMismatch {
            let unixTime = try container.decode(TimeInterval.self)
            return Date(timeIntervalSince1970: unixTime)
        }

    }
}

extension DateFormatter {
    convenience init(_ format: String) {
        self.init()
        dateFormat = format
        timeZone = .serverTimeZone
    }

    static var withDots = DateFormatter("dd.MM.yyyy")

    static var taskFull = DateFormatter("dd.MM.yyyy hh:mm")

    static var niceDate = DateFormatter("MMM d, yyyy")
}

public extension TimeZone {
    static let serverTimeZone = TimeZone(abbreviation: "MSK")!
}
