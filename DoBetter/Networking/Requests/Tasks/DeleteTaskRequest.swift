//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct DeleteTaskRequest {
    let uid: String
}

extension DeleteTaskRequest: Request, Authorizable {
    typealias Result = UpdateProfileResponse

    public var parameters: [String: Any]? {
        Self.makeParameters(["uid": uid])
    }

    public var path: String { "/v1/task" }

    public var method: Moya.Method { .delete }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateProfileResponse(success: true))) ?? Data()
        return json
    }
}
