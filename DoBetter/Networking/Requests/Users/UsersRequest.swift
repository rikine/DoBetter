//
// Created by Никита Шестаков on 01.04.2023.
//

import Foundation
import Moya

struct UsersRequest {
    let lastUid: String?
    let count: Int?

    let neededUsersIds: [String]?
    let filter: String?
}

extension UsersRequest: Request, Authorizable {
    typealias Result = [ProfileModel]

    public var parameters: [String: Any]? {
        Self.makeParameters(["lastUid": lastUid, "count": count, "neededUsersIds": neededUsersIds, "filterNameOrNickname": filter])
    }

    public var path: String { "/v1/users" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(Self.models)) ?? Data()
        return json
    }
    
    public static var models: [ProfileModel] {
        [
            .init(nickname: "test1", name: "Test Name1", uid: "test1", photoName: nil, isEditable: true, description: nil, isSecure: false),
            .init(nickname: "test2", name: "Test Name2", uid: "test2", photoName: nil, isEditable: false, description: "Description 2", isSecure: false),
            .init(nickname: "test3", name: "Test Name3", uid: "test3", photoName: nil, isEditable: false, description: "Description 3", isSecure: false),
            .init(nickname: "test4", name: "Test Name4", uid: "test4", photoName: nil, isEditable: false, description: "Description 4", isSecure: false),
            .init(nickname: "test5", name: "Test Name5", uid: "test5", photoName: nil, isEditable: false, description: "Description 5", isSecure: false),
            .init(nickname: "test6", name: "Test Name6", uid: "test6", photoName: nil, isEditable: false, description: "Description 6", isSecure: false),
            .init(nickname: "test7", name: "Test Name7", uid: "test7", photoName: nil, isEditable: false, description: "Description 7", isSecure: false)
        ]
    }
}
