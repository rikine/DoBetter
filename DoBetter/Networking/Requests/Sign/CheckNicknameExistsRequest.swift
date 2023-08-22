//
// Created by Никита Шестаков on 26.04.2023.
//

import Foundation
import Moya

struct CheckNicknameExistsRequest {
    let nickname: String

    init(nickname: String) {
        self.nickname = nickname
    }
}

extension CheckNicknameExistsRequest: Request {
    typealias Result = PhoneExists

    public var parameters: [String: Any]? { Self.makeParameters(["nickname": nickname]) }
    public var path: String { "/v1/user/check/nickname" }
    public var method: Moya.Method { .get }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(PhoneExists(isExists: nickname == "test"))) ?? Data()
        return json
    }
}
