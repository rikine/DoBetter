//
// Created by Никита Шестаков on 01.04.2023.
//

import Foundation
import Moya

struct UserRequest {
    let userId: String

    init(userId: String) {
        self.userId = userId
    }
}

extension UserRequest: Request, Authorizable {
    typealias Result = ProfileModel

    public var parameters: [String: Any]? {
        Self.makeParameters(["uid": userId])
    }

    public var path: String { "/v1/user" }

    public var method: Moya.Method { .get }
    
    public var sampleData: Data {
        (try? JSONEncoder().encode(UsersRequest.models.first(where: \.uid, is: userId) ?? UsersRequest.models[0])) ?? Data()
    }
}
