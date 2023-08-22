//
// Created by Никита Шестаков on 04.03.2023.
//

import Foundation

public struct LocalAction: Equatable {
    public init(rawCode: String, code: Code?, payload: Payload) {
        self.rawCode = rawCode
        self.code = code
        self.payload = payload
    }

    public init(code: Code, payload: Payload) {
        self.rawCode = code.rawValue
        self.code = code
        self.payload = payload
    }

    /// Returns true if action won't route somewhere
    public var silent: Bool { false }

    public var shouldUnwindToRoot: Bool { true }

    public enum Code: String, Equatable {
        case myFeed, otherFeed
    }

    public enum Payload: Equatable {
        case none
        case invalid
    }

    public static let scheme = "dobetter"
    public var rawCode: String
    public var code: Code?
    public var payload: Payload

    enum Error: Swift.Error {
        case invalidData
    }

    // swiftlint:disable cyclomatic_complexity
    public static func fromDict(dict: [AnyHashable: Any]) -> Self? {
        guard let rawCode = (dict["partition_code"] ?? dict["JumpToLocalPage"]) as? String else {
            return nil
        }
        guard let code = Code(rawValue: rawCode) else {
            return LocalAction(rawCode: rawCode, code: nil, payload: .none)
        }

        var payload: Payload
        let additionalParam = dict["additional_param"] as? String

        do {
            switch code {
            default: payload = .none
            }
        } catch {
            payload = .invalid
        }

        return LocalAction(rawCode: rawCode, code: code, payload: payload)
    }

    public static func fromURL(url: URL) -> Self? {

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let rawCode = components.host?.uppercased()
        else {
            return nil
        }

        guard let code = Code(rawValue: rawCode) else {
            return LocalAction(rawCode: rawCode, code: nil, payload: .none)
        }

        var payload: Payload
        let parameters = components.queryItems?.dict ?? [:]
        let path = url.pathComponents.filter { $0 != "/" } // ¯\_(ツ)_/¯ first component is "/"

        do {
            switch code {
            default:
                payload = .none
            }
        } catch {
            payload = .invalid
        }

        return LocalAction(rawCode: rawCode, code: code, payload: payload)
    }

    public static func fromDynamicLink(url: URL) -> Self? {
        guard url.scheme == "https" else { return nil }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let parameters = components.queryItems?.dict ?? [:]

        var rawCode: String
        var linkParameters: [String: String] = [:]

        if parameters.keys.contains("storyId") {
            rawCode = "STORY"
            linkParameters = parameters
        } else {
            guard let link = parameters["link"], let linkURL = URL(string: link) else {
                return nil
            }

            rawCode = linkURL.lastPathComponent.uppercased()

            guard let linkComponents = URLComponents(url: linkURL, resolvingAgainstBaseURL: false) else {
                return nil
            }

            linkParameters = linkComponents.queryItems?.dict ?? [:]
        }

        guard let code = Code(rawValue: rawCode) else {
            return LocalAction(rawCode: rawCode, code: nil, payload: .none)
        }

        var payload: Payload

        do {
            switch code {
            default: payload = .none
            }
        } catch {
            payload = .invalid
        }

        return LocalAction(rawCode: rawCode, code: code, payload: payload)
    }
}

extension LocalAction: Decodable {

    /// { ...
    /// "JumpToLocalPage" : "SETTINGS",
    /// ... }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self),
           let action = LocalAction.fromDict(dict: ["JumpToLocalPage": string]) {
            self = action
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath,
                                                debugDescription: "Unable to decode LocalActionEnum")
            throw DecodingError.dataCorrupted(context)
        }
    }

}

extension Array where Element == URLQueryItem {
    var dict: [String: String] {
        reduce(into: [String: String]()) {
            $0[$1.name] = $1.value
        }
    }

    public subscript(itemName: String) -> String? {
        first(where: \.name, is: itemName)?.value
    }
}
