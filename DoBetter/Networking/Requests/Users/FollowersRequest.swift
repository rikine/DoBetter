//
// Created by Никита Шестаков on 01.04.2023.
//

import Foundation
import Moya

struct FollowingsRequest {
    let lastUid: String?
    let count: Int?

    let neededUserUid: String
    let filter: String?
}

extension FollowingsRequest: Request, Authorizable {
    typealias Result = [ProfileModel]

    public var parameters: [String: Any]? {
        Self.makeParameters(["lastUid": lastUid, "count": count, "uid": neededUserUid, "filterNameOrNickname": filter])
    }

    public var path: String { "/v1/users/followings" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(Array(UsersRequest.models.suffix(3)))) ?? Data()
        return json
    }
}
