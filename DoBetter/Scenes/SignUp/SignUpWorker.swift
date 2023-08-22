//
//  SignUpWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 07.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

class SignUpWorker {
    private let service: NetworkServiceProtocol
    private let firebaseAuthService: FirebaseAuthServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared,
         firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService.shared) {
        self.service = service
        self.firebaseAuthService = firebaseAuthService
    }

    func signUp(nickname: String, email: String, password: String) async throws {
        do {
            guard !CommandLine.arguments.contains("test") else { return }
            let user = try await firebaseAuthService.auth(with: .email(email: email, password: password, isSignUp: true))
            let _ = try await service.request(CreateNewUser(uid: user?.uid ?? guardUnreachable(UUID().uuidString), nickname: nickname))
        } catch {
            try? firebaseAuthService.signOut()
            throw error
        }
    }

    func checkNicknameExists(nickname: String) async throws {
        let resultNick = try await service.request(CheckNicknameExistsRequest(nickname: nickname))
        if resultNick.isExists {
            throw SignModelPresenter.Error.nicknameExists
        }
    }

    func checkPhoneExists(phone: String) async throws {
        let resultPhone = try await service.request(CheckPhoneExistsRequest(phone: phone))
        if resultPhone.isExists { throw SignModelPresenter.Error.phoneNumberExists }
    }
}
