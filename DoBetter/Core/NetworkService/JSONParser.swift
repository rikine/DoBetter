//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation

public indirect enum JSON: Equatable {
    case null
    case string(String)
    case number(String)
    case bool(Bool)
    case dictionary([String: JSON])
    case array([JSON])
}

public struct JSONParser {
    public enum Error: Swift.Error, Equatable {
        public enum String: Swift.Error, Equatable {
            case escapeSequence(index: Int)
            case escapeCharacter(index: Int)
            case malformedUnicode(index: Int)
            case unterminated(index: Int)
        }
        public enum Number: Swift.Error, Equatable {
            case malformed(index: Int)
            case numberBeginningWithZero(index: Int)
        }
        public enum Bool: Swift.Error, Equatable {
            case malformed(index: Int)
        }
        public enum Null: Swift.Error, Equatable {
            case malformed(index: Int)
        }
        public enum Array: Swift.Error, Equatable {
            case malformed(index: Int)
        }
        public enum Dictionary: Swift.Error, Equatable {
            case malformed(index: Int)
        }
        case empty
        case invalidCharacter(UnicodeScalar, index: Int)
        case string(String)
        case number(Number)
        case bool(Bool)
        case null(Null)
        case array(Array)
        case dictionary(Dictionary)
    }

    public static func parse(data: Data) -> Either<Error, JSON> {
        guard let string = String(data: data, encoding: .utf8) else { return .left(.empty) }
        var index = 0
        return parse(scalars: Array(string.unicodeScalars), index: &index)
    }

    private static func parse(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error, JSON> {
        while index < scalars.endIndex {
            guard !CharacterSet.whitespacesAndNewlines.contains(scalars[index]) else {
                index += 1
                continue
            }
            switch scalars[index] {
            case "{":
                return parseDictionary(scalars: scalars, index: &index).mapRight(JSON.dictionary)
            case "[":
                return parseArray(scalars: scalars, index: &index).mapRight(JSON.array)
            case "\"":
                return parseString(scalars: scalars, index: &index).biMap(left: Error.string, right: JSON.string)
            case "-", "0"..."9":
                return parseNumber(scalars: scalars, index: &index).biMap(left: Error.number, right: JSON.number)
            case "n":
                return parseNull(scalars: scalars, index: &index).mapLeft(Error.null)
            case "t", "f":
                return parseBool(scalars: scalars, index: &index).biMap(left: Error.bool, right: JSON.bool)
            default:
                return .left(.invalidCharacter(scalars[index], index: index))
            }
        }
        return .left(.empty)
    }

    internal static func parseDictionary(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error, [String: JSON]> {
        let startIndex = index
        guard index < scalars.endIndex,
              scalars[index] == "{"
        else { return .left(.dictionary(.malformed(index: index))) }
        var elements: [String: JSON] = [:]
        index += 1
        while index < scalars.endIndex, scalars[index] != "}" {
            switch scalars[index] {
            case _ where CharacterSet.whitespacesAndNewlines.contains(scalars[index]):
                index += 1
            case "\"":
                let key = parseString(scalars: scalars, index: &index).mapLeft(Error.string)
                while index < scalars.endIndex, scalars[index] != ":", CharacterSet.whitespacesAndNewlines.contains(scalars[index]) {
                    index += 1
                }
                index += 1
                guard index < scalars.endIndex
                else { return .left(.dictionary(.malformed(index: startIndex))) }
                let value = parse(scalars: scalars, index: &index)
                switch key.zipRight(with: value) {
                case let .right((key, value)):
                    elements[key] = value
                case let .left(error):
                    return .left(error)
                }
                while index < scalars.endIndex, scalars[index] != "," {
                    switch scalars[index] {
                    case _ where CharacterSet.whitespacesAndNewlines.contains(scalars[index]):
                        index += 1
                    case "}":
                        index += 1
                        return .right(elements)
                    default:
                        return .left(.dictionary(.malformed(index: index)))
                    }
                }
                index += 1
            default:
                return .left(.dictionary(.malformed(index: index)))
            }
        }
        guard index < scalars.endIndex
        else { return .left(.dictionary(.malformed(index: startIndex))) }
        index += 1
        return .right(elements)
    }

    internal static func parseArray(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error, [JSON]> {
        let startIndex = index
        guard index < scalars.endIndex,
              scalars[index] == "["
        else { return .left(.array(.malformed(index: startIndex))) }
        var elements: [JSON] = []
        index += 1
        while index < scalars.endIndex, scalars[index] != "]" {
            switch scalars[index] {
            case ",":
                return .left(.array(.malformed(index: startIndex)))
            case _ where CharacterSet.whitespacesAndNewlines.contains(scalars[index]):
                index += 1
            default:
                switch parse(scalars: scalars, index: &index) {
                case .left(let error):
                    return .left(error)
                case .right(let value):
                    elements.append(value)
                }
                while index < scalars.endIndex, scalars[index] != "," {
                    switch scalars[index] {
                    case _ where CharacterSet.whitespacesAndNewlines.contains(scalars[index]):
                        index += 1
                    case "]":
                        index += 1
                        return .right(elements)
                    default:
                        return .left(.array(.malformed(index: startIndex)))
                    }
                }
                index += 1
            }
        }
        guard index < scalars.endIndex
        else { return .left(.array(.malformed(index: startIndex))) }
        index += 1
        return .right(elements)
    }

    internal static func parseNull(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error.Null, JSON> {
        guard index < scalars.endIndex
        else { return .left(.malformed(index: index)) }
        let literal = "null"
        if scalars.dropFirst(index).prefix(literal.count) == ArraySlice(literal.unicodeScalars) {
            index += literal.count
            return .right(.null)
        } else {
            return .left(.malformed(index: index))
        }
    }

    internal static func parseBool(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error.Bool, Bool> {
        guard index < scalars.endIndex
        else { return .left(.malformed(index: index)) }
        let (t, f) = (true, false)
        switch scalars[index] {
        case "t" where scalars.dropFirst(index).prefix(t.description.count) == ArraySlice(t.description.unicodeScalars):
            index += t.description.count
            return .right(t)
        case "f" where scalars.dropFirst(index).prefix(f.description.count) == ArraySlice(f.description.unicodeScalars):
            index += f.description.count
            return .right(f)
        default:
            return .left(.malformed(index: index))
        }
    }

    internal static func parseString(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error.String, String> {
        guard index < scalars.endIndex
        else { return .left(.unterminated(index: index)) }
        var string = [UnicodeScalar]()
        let startIndex = index
        guard scalars[index] == "\""
        else { return .left(.unterminated(index: startIndex)) }
        index += 1
        while index < scalars.endIndex, scalars[index] != "\"" {
            switch scalars[index] {
            case "\\":
                guard index + 1 < scalars.endIndex else { return .left(.escapeSequence(index: startIndex)) }
                index += 1
                switch scalars[index] {
                case "/", "\\", "\"":
                    string.append(scalars[index])
                case "n":
                    string.append("\n")
                case "r":
                    string.append("\r")
                case "t":
                    string.append("\t")
                case "f":
                    string.append(.init(12))
                case "b":
                    string.append(.init(8))
                case "u":
                    // Unicode scalar value: a number from 0 to 0x10FFFF defined by applying
                    // the following algorithm to a character sequence S:
                    //
                    // If S is a single, nonsurrogate value <U>
                    // N = U
                    let singleHex = scalars.toHex(in: (index + 1)...(index + 4))

                    if let singleUnicode = singleHex.flatMap(UnicodeScalar.init) {
                        string.append(singleUnicode)
                        index += 4
                    } else {
                        // If S is surrogate pair <H, L>
                        // (H - 0xD800) * 0х400 + (L - 0xDC00) + 0x10000
                        let left = singleHex ?? .zero
                        let right = scalars.toHex(in: (index + 7)...(index + 10)) ?? .zero
                        let surrogatePairHex = (left - 0xD800) * 0x400 + (right - 0xDC00) + 0x10000
                        if let surrogatePairUnicode = UnicodeScalar(surrogatePairHex) {
                            string.append(surrogatePairUnicode)
                            index += 10
                        } else {
                            return .left(.malformedUnicode(index: startIndex))
                        }
                    }
                default:
                    return .left(.escapeCharacter(index: index))
                }
            default:
                string.append(scalars[index])
            }
            index += 1
        }
        guard index < scalars.endIndex, scalars[index] == "\""
        else { return .left(.unterminated(index: startIndex)) }
        index += 1
        return .right(String(string.map(Character.init)))
    }

    internal static func parseNumber(scalars: Array<UnicodeScalar>, index: inout Array<UnicodeScalar>.Index) -> Either<Error.Number, String> {
        guard index < scalars.endIndex
        else { return .left(.malformed(index: index)) }
        let transform: ([UnicodeScalar]) -> Either<Error.Number, String> = { .right(String($0.map(Character.init))) }
        var number: [UnicodeScalar] = []
        let startIndex = index
        switch scalars[index] {
        case "-":
            number.append(scalars[index])
            index += 1
        default:
            break
        }

        // Append all digits occurring until a non-digit is found.
        var significant: [UnicodeScalar] = []
        while index < scalars.endIndex, isNumeric(scalars[index]) {
            significant.append(scalars[index])
            index += 1
        }

        switch (significant.first, significant.dropFirst().first) {
        case ("0"?, _?):
            return .left(.numberBeginningWithZero(index: startIndex))
        default:
            break
        }

        number.append(contentsOf: significant)

        guard index < scalars.endIndex
        else { return transform(number) }

        switch scalars[index] {
        case ".":
            number.append(scalars[index])
            index += 1
            guard index < scalars.endIndex, isNumeric(scalars[index])
            else { return .left(.malformed(index: index)) }
            while index < scalars.endIndex, isNumeric(scalars[index]) {
                number.append(scalars[index])
                index += 1
            }
            guard index < scalars.endIndex
            else { return transform(number) }
        default:
            break
        }

        switch scalars[index] {
        case "e", "E":
            number.append(scalars[index])
            index += 1
            guard index < scalars.endIndex
            else { return .left(.malformed(index: startIndex)) }
            switch scalars[index] {
            case "-", "+":
                number.append(scalars[index])
                index += 1
                guard index < scalars.endIndex, isNumeric(scalars[index])
                else { return .left(.malformed(index: startIndex)) }
            case _ where isNumeric(scalars[index]):
                break
            default:
                return .left(.malformed(index: startIndex))
            }
            while index < scalars.endIndex, isNumeric(scalars[index]) {
                number.append(scalars[index])
                index += 1
            }
        default:
            break
        }

        return transform(number)
    }
}

internal extension JSONParser {
    static func isNumeric(_ scalar: UnicodeScalar) -> Bool {
        switch scalar {
        case "0"..."9":
            return true
        default:
            return false
        }
    }
}

extension Array where Element == UnicodeScalar {
    func toString(in range: ClosedRange<Int>) -> String? {
        guard range.lowerBound > 0, range.upperBound < count else { return nil }
        return String(self[range.lowerBound...range.upperBound].map(Character.init))
    }

    func toHex(in range: ClosedRange<Int>) -> UInt32? {
        guard let string = toString(in: range) else { return nil }
        return UInt32(string.uppercased(), radix: 16)
    }
}
