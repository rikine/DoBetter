//
// Created by Никита Шестаков on 11.04.2023.
//

import Foundation
import Moya

struct TaskStatisticsRequest {
    let uid: String
}

extension TaskStatisticsRequest: Request, Authorizable {
    typealias Result = StatisticsModel

    public var parameters: [String: Any]? { ["uid": uid] }

    public var path: String { "/v1/tasks/statistics" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(StatisticsModel.test)) ?? Data()
        return json
    }
}
