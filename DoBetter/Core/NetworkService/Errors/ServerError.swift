//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation

//
//  ServerError.swift
//  VisionInvest
//
//  Created by Maria Ionchenkova on 01/08/2017.
//  Copyright © 2017 openbank. All rights reserved.
//

import Foundation

public struct ServerError: Error, Equatable {

    public let status: HTTPStatusCode
    public let code: String?
    public let message: String
    static let technicalError = ServerError(status: 701, code: "InaccessibilityError", message: "Server on techno")

    public init(status: HTTPStatusCode, code: String?, message: String) {
        self.status = status
        self.code = code
        self.message = message
    }

    public func isSame(as error: ServerError) -> Bool {
        status == error.status && code == error.code
    }
}

extension ServerError: Decodable {

    private enum CodingKeys: String, CodingKey {
        case status = "Error"
        case code = "ErrorCode"
        case message = "ErrorMessageText"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let statusCode = Int(try container.decode(String.self, forKey: .status)) {
            status = HTTPStatusCode(rawValue: statusCode)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .status,
                                                   in: container,
                                                   debugDescription: "Expected an HTTP status code")
        }

        code = try container.decodeIfPresent(String.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
    }
}

extension ServerError: CustomStringConvertible {
    public var description: String { message }
}

extension ServerError: CustomDebugStringConvertible {
    public var debugDescription: String {
        let codeString = code.map { "code: \($0.debugDescription), " } ?? ""
        return "ServerError(status: \(status.debugDescription), \(codeString)message: \(message.debugDescription))"
    }
}

extension ServerError: LocalizedError {
    public var errorDescription: String? { message }
}
