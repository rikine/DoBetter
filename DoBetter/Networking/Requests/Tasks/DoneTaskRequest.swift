//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct DoneTaskRequest {
    let uid: String
}

extension DoneTaskRequest: Request, Authorizable {
    typealias Result = UpdateProfileResponse

    public var parameters: [String: Any]? {
        Self.makeParameters(["uid": uid])
    }

    public var path: String { "/v1/tasks/done" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateProfileResponse(success: true))) ?? Data()
        return json
    }
}
