//
//  TaskWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 18.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class TaskWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func fetchUser(userId: String) async throws -> ProfileModel {
        try await service.request(UserRequest(userId: userId))
    }

    func removeTask(id: String) async throws {
        try await service.request(DeleteTaskRequest(uid: id))
    }

    func makeTaskDone(uid: String) async throws {
        try await service.request(DoneTaskRequest(uid: uid))
    }

    func fetchTask(uid: String) async throws -> TaskModel {
        try await service.request(TaskRequest(uid: uid))
    }

    func likeTask(uid: String) async throws {
        try await service.request(LikeTaskRequest(uid: uid))
    }
}
