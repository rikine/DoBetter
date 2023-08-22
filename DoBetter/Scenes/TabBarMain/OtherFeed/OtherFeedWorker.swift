//
//  OtherFeedWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class OtherFeedWorker: FeedWorker {
    let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func fetchTasks(lastUid: String?, count: Int? = 20, neededIds: [String]? = nil, forUserUid: String? = nil, filter: MyFeed.Filters?) async throws -> [TaskModel] {
        if let forUserUid {
            return (try await service.request(TasksRequest(lastUid: lastUid, count: count, forUserUid: forUserUid,
                                                           neededIds: neededIds, filter: filter))).tasks
        } else {
            return (try await service.request(FollowingsTasksRequest(lastUid: lastUid, count: count, neededIds: neededIds,
                                                                     forUserUid: forUserUid, filter: filter))).tasks
        }
    }
}
