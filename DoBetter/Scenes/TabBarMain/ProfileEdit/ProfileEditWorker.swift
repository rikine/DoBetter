//
//  ProfileEditWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

class ProfileEditWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func updateProfile(nickname: String, name: String?, description: String?, image: UIImage?, shouldRemoveImage: Bool) async throws {
        try await service.request(UpdateUserRequest(nickname: nickname, name: name, description: description,
                                                    image: image, shouldRemoveImage: shouldRemoveImage))
    }
}
