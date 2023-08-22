//
// Created by Никита Шестаков on 07.03.2023.
//

import Foundation
import UIKit
import PhoneNumberKit

final class SignModelPresenter {
    typealias Sign = Localization.Sign

    static func makeInputCell(inputID: CommonInputID, placeholder: String, label: String? = nil, value: String? = nil, info: String? = nil,
                              leftIcon: IconModel? = nil, isSecure: Bool = false,
                              isPhone: Bool = false) -> InputCell.Model {
        .init(inputModel: .init(inputID: inputID,
                                label: label?.style(.label),
                                placeholder: placeholder.style(.line.secondary),
                                value: value?.style(.line.secondary),
                                info: info?.style(.label),
                                typingAttributes: TextStyle.line.attributes,
                                isEditable: true,
                                maxLength: 100,
                                shouldHighlightOnFocus: true,
                                leftIcon: leftIcon,
                                isSecure: isSecure,
                                isPhone: isPhone))
    }

    enum Error: LocalizedError {
        case incorrectPassword, allFieldsRequired, differentPasswords, incorrectNickName, incorrectEmail, incorrectPhone,
             phoneNumberExists, phoneNumberNotExists, nicknameExists

        var errorDescription: String? {
            switch self {
            case .incorrectPassword: return Sign.incorrectPassword.localized
            case .allFieldsRequired: return Sign.allFieldsRequired.localized
            case .differentPasswords: return Sign.differentPasswords.localized
            case .incorrectNickName: return Sign.incorrectNickName.localized
            case .incorrectEmail: return Sign.incorrectEmail.localized
            case .incorrectPhone: return Sign.incorrectPhone.localized
            case .phoneNumberExists: return Sign.phoneNumberExists.localized
            case .phoneNumberNotExists: return Sign.phoneNumberNotExists.localized
            case .nicknameExists: return Sign.nicknameExists.localized
            }
        }
    }

    static func check(nickname: String? = nil, email: String? = nil, password: String? = nil,
                      reenteredPassword: String? = nil, phone: String? = nil) throws {
        guard !(nickname?.isEmpty ?? false), !(email?.isEmpty ?? false),
              !(password?.isEmpty ?? false), !(reenteredPassword?.isEmpty ?? false), !(phone?.isEmpty ?? false) else {
            throw SignModelPresenter.Error.allFieldsRequired
        }
        if let nickname {
            if !nickname.matches(regex: .nicknameRegex) { throw SignModelPresenter.Error.incorrectNickName }
        }
        if let email {
            if !email.matches(regex: .emailRegex) { throw SignModelPresenter.Error.incorrectEmail }
        }
        if let reenteredPassword, password != reenteredPassword { throw SignModelPresenter.Error.differentPasswords }
        if let password {
            if !password.matches(regex: .passwordRegex) { throw SignModelPresenter.Error.incorrectPassword }
        }
        if let phone {
            if !PhoneNumberKit().isValidPhoneNumber(phone) { throw SignModelPresenter.Error.incorrectPhone }
        }
    }
}
