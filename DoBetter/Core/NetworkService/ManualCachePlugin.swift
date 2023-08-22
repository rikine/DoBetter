//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation
import Moya

public protocol ManualCacheableRequest {
    var manualCacheMaxAge: TimeInterval { get }
    /// Ignore any cached result, fetch Request from the remote and update cache
    var preventCache: Bool { get }
    var urlCache: URLCache { get }
}

extension ManualCacheableRequest {
    public var preventCache: Bool { false }
    public var urlCache: URLCache { .shared }
}

extension TargetType {
    public var urlRequest: URLRequest? {
        var urlComponents = URLComponents(url: self.baseURL.appendingPathComponent(self.path),
                                          resolvingAgainstBaseURL: false)
        let params = ((self as? MultiTarget)?.target as? AnyRequest)?.parameters?.map {
                    URLQueryItem(name: "\($0)", value: "\($1)")
                }
                .sorted {
                    $0.name < $1.name
                }
        urlComponents?.queryItems = params
        if let url = urlComponents?.url {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        }
        return nil
    }
}

internal final class ManualCachePlugin: PluginType {

    static let `default` = ManualCachePlugin()

    init() {}

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        guard let manualCache = ((target as? MultiTarget)?.target as? ManualCacheableRequest) else {
            request.cachePolicy = .reloadIgnoringCacheData
            return request
        }
        if manualCache.preventCache {
            request.cachePolicy = .reloadIgnoringCacheData
        } else {
            request.setValue("\(Int(manualCache.manualCacheMaxAge))", forHTTPHeaderField: "Access-Control-Max-Age")
            if manualCache.urlCache.cachedResponse(for: request) != nil {
                request.cachePolicy = .returnCacheDataDontLoad
            }
        }
        return request
    }

    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard let manualCache = ((target as? MultiTarget)?.target as? ManualCacheableRequest) else {
            return result
        }
        let maxAge = manualCache.manualCacheMaxAge
        let urlCache = manualCache.urlCache

        guard let request = result.value?.request ?? target.urlRequest, let url = request.url else {
            return result
        }

        guard let response = result.value?.response, response.statusCode == 200, let data = result.value?.data else {
            if !manualCache.preventCache, let response = urlCache.cachedResponse(for: request) {
                Logger.networking.debug("MANUAL CACHE \(url) - from cache")
                return Result.success(Response(statusCode: 200,
                                               data: response.data,
                                               request: request,
                                               response: response.response as? HTTPURLResponse))
            }
            return result
        }

        let isFromCache: Bool
        if response.allHeaderFields["Manual-Cache-Expires"] != nil {
            isFromCache = true
        } else {
            isFromCache = false
        }
        Logger.networking.debug("MANUAL CACHE \(url) - from \(isFromCache ? "cache" : "internet")")

        var headers = [String: String]()
        headers["Content-Type"] = response.allHeaderFields["Content-Type"] as? String
        headers["Connection"] = response.allHeaderFields["Connection"] as? String
        headers["Content-Length"] = response.allHeaderFields["Content-Length"] as? String
        headers["Access-Control-Max-Age"] = "\(Int(maxAge))"
        headers["Cache-Control"] = "private, max-age=\(Int(maxAge))"
        headers["Manual-Cache-Expires"] = "\(NSDate().timeIntervalSince1970 + maxAge)"

        let newResponse = HTTPURLResponse(url: url,
                                          statusCode: response.statusCode,
                                          httpVersion: "HTTP/1.1",
                                          headerFields: headers)

        if let newResponse = newResponse {
            var request = request
            request.cachePolicy = .useProtocolCachePolicy
            if manualCache.preventCache {
                urlCache.removeCachedResponse(for: request)
            }
            urlCache.storeCachedResponse(CachedURLResponse(response: newResponse,
                                                           data: data,
                                                           userInfo: nil,
                                                           storagePolicy: .allowed),
                                         for: request)
        }

        return result
    }

}

extension Result {
    public var value: Success? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }
}
