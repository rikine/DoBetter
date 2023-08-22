//
//  SearchFollowingsWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class SearchFollowingsWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func fetchUsers(from fromUid: String?, count: Int? = 20, for uid: String?,
                    with type: SearchFollowings.SearchType, filter: String?, neededUsersIds: [String]? = nil) async throws -> [ProfileModel] {
        switch type {
        case .all: return try await service.request(UsersRequest(lastUid: fromUid, count: count, neededUsersIds: neededUsersIds, filter: filter))
        case .followings: return try await service.request(FollowingsRequest(lastUid: fromUid, count: count, neededUserUid: uid ?? "current", filter: filter))
        case .followers: return try await service.request(FollowersRequest(lastUid: fromUid, count: count, neededUserUid: uid ?? "current", filter: filter))
        }
    }

    func followUser(with uid: String) async throws {
        try await service.request(FollowRequest(followingUid: uid))
    }
}

