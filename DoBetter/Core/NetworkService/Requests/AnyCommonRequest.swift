//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation
import Moya

public struct AnyCommonRequest {
    public let url: URL
    public let components: URLComponents?
    public let cacheMaxAge: TimeInterval?

    public init(url: URL, cacheMaxAge: TimeInterval? = nil) {
        self.url = url
        self.cacheMaxAge = cacheMaxAge
        components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    }
}

extension AnyCommonRequest: Request {

    public typealias Result = Data

    public var path: String { components?.path ?? url.absoluteString }

    public var baseURL: URL {
        if let components = components,
           let host = components.host,
           let scheme = components.scheme,
           let url = URL(string: "\(scheme)://\(host)") {
            return url
        } else {
            return assertionUnwrap(optional: nil)
        }
    }

    public var method: Moya.Method { .get }

    public var parameters: [String : Any]? {
        var params = [String : Any]()
        if let items = components?.queryItems {
            for item in items {
                params[item.name] = item.value
            }
        }
        return params
    }
}

extension AnyCommonRequest: ManualCacheableRequest {
    public var manualCacheMaxAge: TimeInterval {
        cacheMaxAge ?? 0
    }

    public var preventCache: Bool {
        cacheMaxAge == nil
    }

}
