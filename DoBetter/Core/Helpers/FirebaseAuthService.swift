//
// Created by Никита Шестаков on 08.03.2023.
//

import Foundation
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import UIKit

enum AuthType {
    enum PhoneStageType {
        case sms(code: String), phone(number: String)
    }

    case email(email: String, password: String, isSignUp: Bool = false)
    case phone(stage: PhoneStageType)
    case google(presentingOn: UIViewController)
}

protocol TokenRepositoryProtocol {
    @discardableResult
    func getToken() async throws -> String

    var getCurrentUid: String { get }
}

protocol FirebaseAuthServiceProtocol: TokenRepositoryProtocol {
    func auth(with: AuthType) async throws -> FirebaseAuth.UserInfo?
    func signOut() throws
}

extension TokenRepositoryProtocol {
    var getCurrentUid: String { Auth.auth().currentUser?.uid ?? "current" }
}

final class FirebaseAuthService: FirebaseAuthServiceProtocol {
    struct ErrorWrapper: LocalizedError {
        let error: Error

        var errorDescription: String? {
            AuthErrorCode.Code.knownErrors.first(where: \.rawValue, is: error._code)?.description
                ?? error.localizedDescription
        }
    }

    enum FirebaseError: LocalizedError {
        case noUser, errorFetchingToken(Error?), errorFetchingVerificationID(Error?), invalidVerificationID,
             cliendIDNotFound, googleVerificationFailed(Error?)

        var errorDescription: String? {
            switch self {
            case .noUser: return Localization.Firebase.noUser.localized
            case .invalidVerificationID: return Localization.Firebase.invalidVerificationID.localized
            case .cliendIDNotFound: return Localization.Firebase.cliendIDNotFound.localized
            case .errorFetchingToken(let error), .errorFetchingVerificationID(let error), .googleVerificationFailed(let error):
                return error.map { ErrorWrapper(error: $0).localizedDescription }
            }
        }
    }

    static let shared: FirebaseAuthServiceProtocol = { FirebaseAuthService() }()

    private init() {}

    private var verificationID: String?

    func auth(with authType: AuthType) async throws -> FirebaseAuth.UserInfo? {
        do {
            switch authType {
            case .email(let email, let password, let isSignUp):
                if isSignUp {
                    return try await signUpWithEmail(email, password: password)
                } else {
                    return try await authWithEmail(email, password: password)
                }
            case let .phone(stage):
                switch stage {
                case .sms(let code):
                    return try await verifyCode(smsCode: code)
                case .phone(let number):
                    return try await authWithPhone(phoneNumber: number)
                }
            case let .google(vc):
                return try await authWithGoogle(on: vc)
            }
        } catch {
            guard error._code != -5 else { return nil } /// Canceled Google sign
            throw ErrorWrapper(error: error)
        }
    }

    func signOut() throws { try Auth.auth().signOut() }

    @discardableResult
    func getToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.noUser
        }

        return try await withCheckedThrowingContinuation { continuation in
            user.getIDToken { token, error in
                guard let token else {
                    continuation.resume(throwing: FirebaseError.errorFetchingToken(error))
                    return
                }

                UserDefaults.standard.set(token, forKey: UserDefaultsKey.profileToken)
                continuation.resume(returning: token)
            }
        }
    }
}

// MARK: Private

private extension FirebaseAuthService {
    func signUpWithEmail(_ email: String, password: String) async throws -> FirebaseAuth.UserInfo {
        let user = try await Auth.auth().createUser(withEmail: email, password: password)
        try await getToken()
        return user.user
    }

    func authWithEmail(_ email: String, password: String) async throws -> FirebaseAuth.UserInfo {
        let provider = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await getTokenByCredential(credential: provider)
    }

    func authWithGoogle(on viewController: UIViewController) async throws -> FirebaseAuth.UserInfo {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw FirebaseError.cliendIDNotFound
        }

        let config = GIDConfiguration(clientID: clientID)

        return try await withCheckedThrowingContinuation { @MainActor continuation in
            GIDSignIn.sharedInstance.signIn(
                with: config,
                presenting: viewController
            ) { [weak self] user, error in
                guard let authentication = user?.authentication,
                      let idToken = authentication.idToken
                else {
                    continuation.resume(throwing: FirebaseError.googleVerificationFailed(error))
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: authentication.accessToken
                )

                Task { [weak self] in
                    do {
                        guard let user = try await self?.getTokenByCredential(credential: credential) else {
                            throw NetworkError.badInput
                        }
                        continuation.resume(returning: user)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// Начинает процесс авторизации через телефон, чтобы его продолжить
    /// нужно вызвать verifyCode с кодом подтверждения, сессия сохраняется в `verificationID`
    func authWithPhone(phoneNumber: String) async throws -> FirebaseAuth.UserInfo? {
        let provider = PhoneAuthProvider.provider()
        return try await withCheckedThrowingContinuation { continuation in
            provider.verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
                guard let verificationID, error == nil else {
                    continuation.resume(throwing: FirebaseError.errorFetchingVerificationID(error))
                    return
                }
                self?.verificationID = verificationID
                continuation.resume(returning: nil)
            }
        }
    }

    func verifyCode(smsCode: String) async throws -> FirebaseAuth.UserInfo {
        guard let verificationID else {
            showError(with: "Что-то пошло не так")
            throw FirebaseError.invalidVerificationID
        }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: smsCode
        )
        return try await getTokenByCredential(credential: credential)
    }

    func getTokenByCredential(credential: AuthCredential) async throws -> FirebaseAuth.UserInfo {
        let user = try await Auth.auth().signIn(with: credential)
        try await getToken()
        return user.user
    }

    func showError(with text: String) {
        DispatchQueue.main.async {
            UIViewController.showOnMainWindow(with: .init(text: text.style(.line.multiline)))
        }
    }
}

extension AuthErrorCode.Code {
    static let knownErrors: [AuthErrorCode.Code] = [
        .captchaCheckFailed, .emailAlreadyInUse, .userDisabled, .operationNotAllowed, .invalidEmail,
        .wrongPassword, .userNotFound, .networkError, .missingEmail, .internalError, .invalidCustomToken,
        .tooManyRequests, .invalidPhoneNumber, .invalidVerificationCode, .quotaExceeded
    ]

    var description: String? {
        switch self {
        case .captchaCheckFailed:
            return Localization.Firebase.captchaCheckFailed.localized
        case .emailAlreadyInUse:
            return Localization.Firebase.emailAlreadyInUse.localized
        case .userDisabled:
            return Localization.Firebase.userDisabled.localized
        case .operationNotAllowed:
            return Localization.Firebase.operationNotAllowed.localized
        case .invalidEmail:
            return Localization.Firebase.invalidEmail.localized
        case .wrongPassword:
            return Localization.Firebase.wrongPassword.localized
        case .userNotFound:
            return Localization.Firebase.userNotFound.localized
        case .networkError:
            return Localization.Firebase.networkError.localized
        case .missingEmail:
            return Localization.Firebase.missingEmail.localized
        case .internalError:
            return Localization.Firebase.internalError.localized
        case .invalidCustomToken:
            return Localization.Firebase.invalidCustomToken.localized
        case .tooManyRequests:
            return Localization.Firebase.tooManyRequests.localized
        case .invalidPhoneNumber:
            return Localization.Firebase.invalidPhoneNumber.localized
        case .invalidVerificationCode:
            return Localization.Firebase.invalidVerificationCode.localized
        case .quotaExceeded:
            return Localization.Firebase.quotaExceeded.localized
        default:
            return nil
        }
    }
}

final class AlmostFakeFirebaseAuthService: FirebaseAuthServiceProtocol {
    func auth(with: AuthType) async throws -> UserInfo? {
        let result = try await Auth.auth().signInAnonymously()
        return result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseAuthService.FirebaseError.noUser
        }

        return try await withCheckedThrowingContinuation { continuation in
            user.getIDToken { token, error in
                guard let token else {
                    continuation.resume(throwing: FirebaseAuthService.FirebaseError.errorFetchingToken(error))
                    return
                }

                UserDefaults.standard.set(token, forKey: UserDefaultsKey.profileToken)
                continuation.resume(returning: token)
            }
        }
    }
}
