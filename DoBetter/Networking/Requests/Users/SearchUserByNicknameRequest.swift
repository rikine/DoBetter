//
// Created by Никита Шестаков on 26.04.2023.
//

import Foundation
import Moya

struct SearchUserByNicknameRequest {
    let nickname: String
}

extension SearchUserByNicknameRequest: Authorizable, Request {
    typealias Result = ProfileModel

    public var parameters: [String: Any]? { ["nickname": nickname] }

    public var path: String { "/v1/user/search" }

    public var method: Moya.Method { .get }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UsersRequest.models[2])) ?? Data()
        return json
    }
}
