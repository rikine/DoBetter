//
// Created by Никита Шестаков on 01.04.2023.
//

import Foundation
import Moya

struct FollowRequest {
    let followingUid: String
}

extension FollowRequest: Request, Authorizable {
    typealias Result = UpdateProfileResponse

    public var parameters: [String: Any]? {
        Self.makeParameters(["followingUid": followingUid])
    }

    public var path: String { "/v1/user/follow" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateProfileResponse(success: true))) ?? Data()
        return json
    }
}
