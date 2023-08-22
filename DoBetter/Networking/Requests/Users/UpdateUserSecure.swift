//
// Created by Никита Шестаков on 16.04.2023.
//

import Foundation
import Moya

struct UpdateUserSecure {  }

extension UpdateUserSecure: Request, Authorizable {
    typealias Result = UpdateUserSecureResponse

    public var parameters: [String: Any]? { nil }

    public var path: String { "/v1/user/secure" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateUserSecureResponse(isSecure: true))) ?? Data()
        return json
    }
}

struct UpdateUserSecureResponse: Codable {
    let isSecure: Bool
}
