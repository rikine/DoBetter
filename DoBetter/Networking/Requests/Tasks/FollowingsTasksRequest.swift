//
// Created by Никита Шестаков on 26.04.2023.
//

import Foundation
import Moya

struct FollowingsTasksRequest {
    let lastUid: String?
    let count: Int?
    let neededIds: [String]?
    let forUserUid: String?
    let filter: MyFeed.Filters?
}

extension FollowingsTasksRequest: Request, Authorizable {
    typealias Result = TasksResponse

    public var parameters: [String: Any]? {
        Self.makeParameters(["lastUid": lastUid,
                             "count": count,
                             "onlyDone": filter?.isOnlyDone,
                             "onlyFromDate": filter?.fromDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "onlyToDate": filter?.toDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "toEndDate": filter?.toEndDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "fromEndDate": filter?.fromEndDate.map(Decoding.dateTimeFormatterWithTimeZone.string),
                             "neededTaskIds": neededIds,
                             "section": filter?.section?.rawValue,
                             "filterTitle": filter?.title,
                             "onlyInProgress": filter?.isOnlyInProgress,
                             "forUserUid": forUserUid])
    }

    public var path: String { "/v1/tasks/followings" }

    public var method: Moya.Method { .post }
    
    public var sampleData: Data {
        if let filter, let name = filter.title?.lowercased() {
            return (try? JSONEncoder().encode(TasksResponse(tasks: Array(CreateTaskRequest.tasks.suffix(6).filter(where: \.title.localizedLowercase, is: name)), last: nil))) ?? Data()
        }
        let json = (try? JSONEncoder().encode(TasksResponse(tasks: Array(CreateTaskRequest.tasks.suffix(6)), last: nil))) ?? Data()
        return json
    }
}
