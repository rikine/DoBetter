//
//  SettingsWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 16.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class SettingsWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func makeSecure() async throws {
        try await service.request(UpdateUserSecure())
    }
}
