//
//  MyFeedWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

protocol FeedWorker {
    var service: NetworkServiceProtocol { get }

    func makeTaskDone(uid: String) async throws
    func likeTask(uid: String) async throws
    func removeTask(id: String) async throws
}

extension FeedWorker {
    func makeTaskDone(uid: String) async throws {
        try await service.request(DoneTaskRequest(uid: uid))
    }

    func likeTask(uid: String) async throws {
        try await service.request(LikeTaskRequest(uid: uid))
    }

    func removeTask(id: String) async throws {
        try await service.request(DeleteTaskRequest(uid: id))
    }
}

class MyFeedWorker: FeedWorker {
    let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func fetchTasks(lastUid: String?, count: Int? = 20, forUserUid: String = "current", neededIds: [String]? = nil, filter: MyFeed.Filters) async throws -> [TaskModel] {
        (try await service.request(TasksRequest(lastUid: lastUid,
                                                count: count,
                                                forUserUid: forUserUid,
                                                neededIds: neededIds,
                                                filter: filter))).tasks
    }

    func fetchTask(uid: String) async throws -> TaskModel {
        try await service.request(TaskRequest(uid: uid))
    }
}
