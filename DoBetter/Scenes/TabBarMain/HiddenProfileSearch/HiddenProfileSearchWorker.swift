//
//  HiddenProfileSearchWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class HiddenProfileSearchWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func fetchUser(with nickname: String) async throws -> ProfileModel {
        try await service.request(SearchUserByNicknameRequest(nickname: nickname))
    }
}
