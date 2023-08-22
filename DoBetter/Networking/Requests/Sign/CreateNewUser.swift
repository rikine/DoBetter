//
// Created by Никита Шестаков on 12.03.2023.
//

import Foundation
import Moya

struct CreateNewUser {
    let uid: String
    let nickname: String

    init(uid: String, nickname: String) {
        self.uid = uid
        self.nickname = nickname
    }
}

extension CreateNewUser: Request {
    typealias Result = User

    public var parameters: [String: Any]? {
        Self.makeParameters(["nickname": nickname, "uid": uid])
    }

    public var path: String { "/v1/user/create" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(User.test)) ?? Data()
        return json
    }
}

struct User: Codable, Equatable {
    let key: String
    let name: String
    let nickname: String
    
    static let test = User(key: "key", name: "name", nickname: "nickname")
}
