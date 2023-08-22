//
//  PhoneCodeEnterWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 11.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation
import FirebaseAuth

class PhoneCodeEnterWorker {
    private let service: NetworkServiceProtocol
    private let firebaseAuthService: FirebaseAuthServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared,
         firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService.shared) {
        self.service = service
        self.firebaseAuthService = firebaseAuthService
    }

    func signIn(number: String) async throws {
        let _ = try await firebaseAuthService.auth(with: .phone(stage: .phone(number: number)))
    }

    func sendCode(nickname: String? = nil, code: String) async throws {
        do {
            let user = try await firebaseAuthService.auth(with: .phone(stage: .sms(code: code)))
            guard let user, let nickname else { return }
            let _ = try await service.request(CreateNewUser(uid: user.uid, nickname: nickname))
        } catch {
            try? firebaseAuthService.signOut()
            throw error
        }
    }
}
