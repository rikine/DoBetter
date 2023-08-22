//
// Created by Никита Шестаков on 01.04.2023.
//

import Foundation
import Moya

struct FollowersRequest {
    let lastUid: String?
    let count: Int?

    let neededUserUid: String
    let filter: String?
}

extension FollowersRequest: Request, Authorizable {
    typealias Result = [ProfileModel]

    public var parameters: [String: Any]? {
        Self.makeParameters(["lastUid": lastUid, "count": count, "uid": neededUserUid, "filterNameOrNickname": filter])
    }

    public var path: String { "/v1/users/followers" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(Array(UsersRequest.models.suffix(2)))) ?? Data()
        return json
    }
}
