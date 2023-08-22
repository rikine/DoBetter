//
//  SignInWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

class SignInWorker {
    private let service: NetworkServiceProtocol
    private let firebaseAuthService: FirebaseAuthServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared,
         firebaseAuthService: FirebaseAuthServiceProtocol = FirebaseAuthService.shared) {
        self.service = service
        self.firebaseAuthService = firebaseAuthService
    }

    func signIn(email: String, password: String) async throws {
        try await firebaseAuthService.auth(with: .email(email: email, password: password))
    }

    func signInWithGoogle(on viewController: UIViewController) async throws  {
        do {
            let user = try await firebaseAuthService.auth(with: .google(presentingOn: viewController))
            let _ = try await service.request(CreateNewUser(uid: user?.uid ?? guardUnreachable(UUID().uuidString),
                                                            nickname: user?.displayName ?? UUID().uuidString))
        } catch {
            try? firebaseAuthService.signOut()
            throw error
        }
    }

    func checkPhoneExists(phone: String) async throws -> PhoneExists {
        try await service.request(CheckPhoneExistsRequest(phone: phone))
    }
}
