//
// Created by Никита Шестаков on 17.04.2023.
//

import Foundation

protocol Localizable: CustomStringConvertible {
    var key: String { get }
    var localized: String { get }
}

extension Localizable {
    var localized: String { key.localizeFormat([]) }

    func localized(_ args: CVarArg...) -> String { key.localizeFormat(args) }

    var description: String { localized }
}

enum Localization: String, Localizable {
    case emailPlaceholder
    case passwordPlaceholder
    case nicknamePlaceholder
    case reenterPasswordPlaceholder
    case phonePlaceholder
    case cancel
    case somethingWentWrong
    case unexpectedError
    case edit
    case done
    case save
    case clear
    case add
    case remove
    case addSmall
    case removeSmall
    case all
    case ok
    case imageUpload
    case deleteImage

    enum SignIn: String, Localizable {
        case `continue`
        case signUp
        case signWithPhone
        case signWithGoogle
        case signWithEmail
        case title

        var key: String { "SignIn." + rawValue }
    }

    enum SignUp: String, Localizable {
        case `continue`
        case signIn
        case signWithPhone
        case signWithEmail
        case title

        var key: String { "SignUp." + rawValue }
    }

    enum Sign: String, Localizable {
        case incorrectPassword
        case allFieldsRequired
        case differentPasswords
        case incorrectNickName
        case incorrectEmail
        case incorrectPhone
        case phoneNumberExists
        case phoneNumberNotExists
        case nicknameExists
        case agreement1
        case agreement2

        var key: String { "Sign." + rawValue }
    }

    enum PhoneCode: String, Localizable {
        case emptyCode
        case codeSent
        case retry
        case send
        case placeholder
        case sendingVerification
        case checkingVerification
        case title
        case sendCodeAfter1
        case sendCodeAfter2
        case questionCode1
        case questionCode2
        case questionCode3

        var key: String { "PhoneCode." + rawValue }
    }

    enum PinCode: String, Localizable {
        case notAvailable
        case passcodeNotSet
        case bioAuthNotEnabled
        case exit
        case exitButton
        case settings
        case tryAgain
        case title

        var key: String { "PinCode." + rawValue }
    }

    enum MyFeed: String, Localizable {
        case searchTaskPlaceholder
        case title
        case filters
        case stopperTitle
        case stopperSubtitle

        var key: String { "MyFeed." + rawValue }

        enum Filters: String, Localizable {
            case dateTo
            case dateFrom
            case endDateFrom
            case endDateTo
            case onlyInProgress
            case onlyDone

            var key: String { "MyFeed.Filters." + rawValue }
        }
    }

    enum OtherFeed: String, Localizable {
        case title
        case stopperTitle
        case stopperSubtitle
        case stopperOtherTitle

        var key: String { "OtherFeed." + rawValue }
    }

    enum Profile: String, Localizable {
        case statisticsLabel
        case statisticsPlaceholder
        case summaryLabel
        case summaryPlaceholder
        case tasksLabel
        case tasksPlaceholder
        case followersLabel
        case followersPlaceholder
        case followingsLabel
        case followingsPlaceholder

        var key: String { "Profile." + rawValue }

        enum Edit: String, Localizable {
            case title
            case nameInfo
            case nicknameInfo
            case descriptionInfo
            case namePlaceholder
            case nicknamePlaceholder
            case descriptionPlaceholder
            case emptyNickname

            var key: String { "Profile.Edit." + rawValue }
        }
    }

    enum SearchUsers: String, Localizable {
        case filterNamePlaceholder
        case users

        var key: String { "SearchUsers." + rawValue }
    }

    enum CreateTask: String, Localizable {
        case titleChange
        case titleCreate
        case infoColor
        case infoSection
        case namePlaceholder
        case nameInfo
        case descriptionPlaceholder
        case descriptionInfo
        case endDate

        var key: String { "CreateTask." + rawValue }
    }

    enum TabBar: String, Localizable {
        case myFeed
        case feed

        var key: String { "TabBar." + rawValue }
    }

    enum Settings: String, Localizable {
        case title
        case bioAuth
        case secure
        case exit
        case confirmExitTitle
        case confirmExitSubtitle
        case disableBioTitle
        case disableBioSubtitle

        var key: String { "Settings." + rawValue }
    }

    enum BioAuth: String, Localizable {
        case titleAlert
        case subtitleAlert
        case kTouchIdAuthenticationReason, kTouchIdPasscodeAuthenticationReason, kSetPasscodeToUseTouchID,
             kNoFingerprintEnrolled, kDefaultTouchIDAuthenticationFailedReason, kFaceIdAuthenticationReason,
             kFaceIdPasscodeAuthenticationReason, kSetPasscodeToUseFaceID, kNoFaceIdentityEnrolled,
             kDefaultFaceIDAuthenticationFailedReason

        var key: String { "BioAuth." + rawValue }
    }

    enum Statistics: String, Localizable {
        case inProgress
        case expired
        case total
        case done

        var key: String { "Statistics." + rawValue }
    }

    enum Task: String, Localizable {
        case title
        case done
        case inProgress
        case new
        case setAsDone
        case setAsNew
        case setAsInProgress
        case description
        case createdAt
        case creator
        case timeLeft
        case noDeadline
        case moreThanDay
        case expired

        enum Section: String, Localizable {
            case none
            case home
            case work
            case business
            case study
            case friends
            case family

            var key: String { "Task.Section." + rawValue }
        }

        var key: String { "Task." + rawValue }
    }

    enum SearchHiddenUser: String, Localizable {
        case title
        case find

        var key: String { "SearchHiddenUser." + rawValue }
    }

    enum Firebase: String, Localizable {
        case captchaCheckFailed
        case emailAlreadyInUse
        case userDisabled
        case operationNotAllowed
        case invalidEmail
        case wrongPassword
        case userNotFound
        case networkError
        case missingEmail
        case internalError
        case invalidCustomToken
        case tooManyRequests
        case invalidPhoneNumber
        case invalidVerificationCode
        case quotaExceeded
        case noUser
        case invalidVerificationID
        case cliendIDNotFound

        var key: String { "Firebase." + rawValue }
    }

    var key: String { rawValue }
}

extension String {
    func localizeFormat(_ args: [CVarArg]) -> String {
        localizeStringFormat(key: self, args: args)
    }

    func localizeStringFormat(key: String, args: CVarArg... ) -> String {
        let format = NSLocalizedString(key, comment: "")
        let result = withVaList(args) {
            (NSString(format: format, locale: NSLocale.current, arguments: $0) as String)
        }
        return result
    }
}
