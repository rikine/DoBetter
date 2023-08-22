//
//  SignInModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

enum SignIn {
    typealias SignInStrings = Localization.SignIn

    enum ScreenType {
        case email, phone

        var buttons: [Button] {
            switch self {
            case .email: return [.continue, .signUp, .signWithPhone, .signWithGoogle]
            case .phone: return [.continue, .signUp, .signWithEmail, .signWithGoogle]
            }
        }

        var inputs: [Input] {
            switch self {
            case .email: return [.email, .password]
            case .phone: return [.phone]
            }
        }
    }

    enum Table {
        struct Response {
            let screen: ScreenType
        }
    }

    enum Input {
        case email, password, nickname, reenterPassword, phone

        var placeholder: String {
            switch self {
            case .email: return Localization.emailPlaceholder.localized
            case .password: return Localization.passwordPlaceholder.localized
            case .nickname: return Localization.nicknamePlaceholder.localized
            case .reenterPassword: return Localization.reenterPasswordPlaceholder.localized
            case .phone: return Localization.phonePlaceholder.localized
            }
        }

        var leftIcon: IconModel? {
            switch self {
            case .email: return .SingIn.email
            case .password, .reenterPassword: return .SingIn.password
            case .nickname: return .SingIn.user
            case .phone: return nil
            }
        }

        var inputID: CommonInputID {
            switch self {
            case .email: return .email
            case .password: return .password
            case .nickname: return .nickname
            case .reenterPassword: return .passwordReenter
            case .phone: return .phone
            }
        }

        var isSecure: Bool {
            self == .password || self == .reenterPassword
        }

        struct Request {
            let text: String
            let type: CommonInputID
        }
    }

    enum Button {
        case `continue`, signUp, signWithPhone, signWithGoogle, signWithEmail

        var title: String {
            switch self {
            case .continue: return SignInStrings.continue.localized
            case .signUp: return SignInStrings.signUp.localized
            case .signWithPhone: return SignInStrings.signWithPhone.localized
            case .signWithGoogle: return SignInStrings.signWithGoogle.localized
            case .signWithEmail: return SignInStrings.signWithEmail.localized
            }
        }

        var style: IBRoundCornersButton.Style {
            switch self {
            case .continue: return .primary
            case .signUp: return .text
            case .signWithPhone, .signWithGoogle, .signWithEmail: return .secondary
            }
        }

        struct ViewModel {
            let button: Button
        }

        struct Request {
            let button: Button
        }
    }
}
