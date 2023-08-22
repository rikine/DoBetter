//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct TaskRequest {
    let uid: String
}

extension TaskRequest: Request, Authorizable {
    typealias Result = TaskModel

    public var parameters: [String: Any]? {
        Self.makeParameters(["uid": uid])
    }

    public var path: String { "/v1/task" }

    public var method: Moya.Method { .get }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(CreateTaskRequest.tasks[0])) ?? Data()
        return json
    }
}
