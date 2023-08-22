//
//  ProfileWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class ProfileWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func fetchUser(with uid: String) async throws -> ProfileModel {
        try await service.request(UserRequest(userId: uid))
    }

    func fetchFollowers(with uid: String) async throws -> [ProfileModel] {
        try await service.request(FollowersRequest(lastUid: nil, count: 15, neededUserUid: uid, filter: nil))
    }

    func fetchFollowings(with uid: String) async throws -> [ProfileModel] {
        try await service.request(FollowingsRequest(lastUid: nil, count: 15, neededUserUid: uid, filter: nil))
    }

    func followUser(with uid: String) async throws {
        try await service.request(FollowRequest(followingUid: uid))
    }

    func fetchTaskStatistics(with uid: String) async throws -> StatisticsModel {
        try await service.request(TaskStatisticsRequest(uid: uid))
    }

    func fetchTasks(for uid: String) async throws -> [TaskModel] {
        (try await service.request(TasksRequest(lastUid: nil,
                                                count: 3,
                                                forUserUid: uid,
                                                neededIds: nil,
                                                filter: nil))).tasks
    }

    func makeTaskDone(uid: String) async throws {
        try await service.request(DoneTaskRequest(uid: uid))
    }

    func likeTask(uid: String) async throws {
        try await service.request(LikeTaskRequest(uid: uid))
    }
}
