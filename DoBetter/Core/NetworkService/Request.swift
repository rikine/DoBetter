//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation
import Moya

struct GlobalConstants {
    static let baseURL = assertionUnwrap(optional: URL(string: "https://dobetterbackend-1-q9170668.deta.app"))
}

public protocol AnyRequest: TargetType {

    var parameters: [String : Any]? { get }

    var parameterEncoding: ParameterEncoding { get }

    /// Cache response by `expirationTime` in `InMemoryResponseCache`
    /// Useful for caching misc data
    /// If you need fine control see `ManualCacheableRequest`
    var prefersCaching: Bool { get }

    /// The success status code that this request expects. Defaults to 200.
    static var successStatusCode: Int { get }
}

public extension AnyRequest {

    var headers: [String : String]? { nil }

    var sampleData: Data { Data() }

    var baseURL: URL { GlobalConstants.baseURL }

    var parameterEncoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    var task: Moya.Task {
        parameters.map { .requestParameters(parameters: $0, encoding: parameterEncoding) } ?? .requestPlain
    }

    var prefersCaching: Bool { false }

    static var successStatusCode: Int { 200 }
}

public protocol Request: AnyRequest {

    associatedtype Result

    static func decodeResult(from response: Moya.Response) throws -> Result

    /// The top-level key of the JSON response. Defaults to `nil`, which means that
    /// we first try deserializing the whole JSON and if that fails,
    /// we use the result type name as the top-level key.
    static var responseTopLevelKey: String? { get }
}

public protocol Authorizable {}

extension Request where Self: Authorizable {
    public var headers: [String: String]? {
        guard let token = UserDefaults.standard.string(forKey: UserDefaultsKey.profileToken) else { return [:] }
        return ["Authorization": "Bearer \(token)"]
    }
}

extension Request {
    internal static func getError(from response: Moya.Response) throws -> ServerError {
        do {
            return try Decoding.decode(ServerError.self,
                                       topLevelKey: "Error",
                                       from: response.data)
        } catch {
            let statusCode = HTTPStatusCode(rawValue: response.statusCode)

            if statusCode.category != .success {
                let message = NSLocalizedString("Произошла непредвиденная ошибка. Повторите попытку позже",
                                                comment: "Сообщение когда сервер лежит")
                return ServerError(status: statusCode,
                                   code: nil,
                                   message: message)
            } else {
                throw error
            }
        }
    }

    public static var responseTopLevelKey: String? { nil }

    public static func makeParameters(_ sourceDict: [String: Any?]) -> [String: Any]? {
        let nonNilDict = sourceDict.compactMapValues { $0 }
        guard !nonNilDict.isEmpty else { return nil }
        return nonNilDict
    }
}

extension Request where Result: Decodable {
    public static func decodeResult(from response: Moya.Response) throws -> Result {
        if response.statusCode == successStatusCode {
            return try Decoding.decode(Result.self,
                                       topLevelKey: responseTopLevelKey,
                                       from: response.data)
        } else {
            throw try getError(from: response)
        }
    }
}

extension Request where Result == Void {
    public static func decodeResult(from response: Moya.Response) throws -> Result {
        guard response.statusCode == successStatusCode else { return }
        throw try getError(from: response)
    }
}

extension Request where Result == Data {
    public static func decodeResult(from response: Moya.Response) throws -> Result {
        if response.statusCode == successStatusCode {
            return response.data
        } else {
            throw try getError(from: response)
        }
    }
}
