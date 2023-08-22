//
//  SignUpModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 07.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

enum SignUp {
    typealias SignUpStrings = Localization.SignUp

    enum Table {
        struct Response {
            let screenType: ScreenType
        }
    }

    enum ScreenType {
        case phone, email

        var inputs: [SignIn.Input] {
            switch self {
            case .phone: return [.nickname, .phone]
            case .email: return [.nickname, .email, .password, .reenterPassword]
            }
        }

        var buttons: [Button] {
            switch self {
            case .phone: return [.continue, .signIn, .signWithEmail]
            case .email: return [.continue, .signIn, .signWithPhone]
            }
        }
    }

    enum Input {
        struct Request {
            let text: String
            let type: CommonInputID
        }
    }

    enum Button {
        case `continue`, signIn, signWithPhone, signWithEmail

        var title: String {
            switch self {
            case .continue: return SignUpStrings.continue.localized
            case .signIn: return SignUpStrings.signIn.localized
            case .signWithPhone: return SignUpStrings.signWithPhone.localized
            case .signWithEmail: return SignUpStrings.signWithEmail.localized
            }
        }

        var style: IBRoundCornersButton.Style {
            switch self {
            case .continue: return .primary
            case .signIn: return .text
            case .signWithPhone, .signWithEmail: return .secondary
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
