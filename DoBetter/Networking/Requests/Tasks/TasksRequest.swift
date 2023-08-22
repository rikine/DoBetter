//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct TasksRequest {
    let lastUid: String?
    let count: Int?

    let forUserUid: String
    let neededIds: [String]?

    let filter: MyFeed.Filters?
}

extension TasksRequest: Request, Authorizable {
    typealias Result = TasksResponse

    public var parameters: [String: Any]? {
        Self.makeParameters(["lastUid": lastUid,
                             "count": count,
                             "forUserUids": [forUserUid],
                             "onlyDone": filter?.isOnlyDone,
                             "onlyFromDate": filter?.fromDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "onlyToDate": filter?.toDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "toEndDate": filter?.toEndDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "fromEndDate": filter?.fromEndDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "neededTaskIds": neededIds,
                             "section": filter?.section?.rawValue,
                             "filterTitle": filter?.title,
                             "onlyInProgress": filter?.isOnlyInProgress])
    }

    public var path: String { "/v1/tasks" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        if let filter, let name = filter.title?.lowercased() {
            return (try? JSONEncoder().encode(TasksResponse(tasks: CreateTaskRequest.tasks.filter(where: \.title.localizedLowercase, is: name), last: nil))) ?? Data()
        }
        let json = (try? JSONEncoder().encode(TasksResponse(tasks: CreateTaskRequest.tasks, last: nil))) ?? Data()
        return json
    }
}

struct TasksResponse: Codable {
    let tasks: [TaskModel]
    let last: String?

    private enum CodingKeys: String, CodingKey {
        case tasks = "items"
        case last = "last"
    }
}
