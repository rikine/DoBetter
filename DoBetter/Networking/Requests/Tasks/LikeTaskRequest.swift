//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct LikeTaskRequest {
    let uid: String
}

extension LikeTaskRequest: Request, Authorizable {
    typealias Result = UpdateProfileResponse

    public var parameters: [String: Any]? {
        Self.makeParameters(["likedUid": uid])
    }

    public var path: String { "/v1/tasks/like" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateProfileResponse(success: true))) ?? Data()
        return json
    }
}
