//
//  PinCodeModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import LocalAuthentication

enum PinCode {
    typealias PinCode = Localization.PinCode

    enum TryToAuth {
        struct Request {}
    }

    enum Alert {
        case notAvailable, passcodeNotSet, bioAuthNotEnabled, exit

        var title: String {
            switch self {
            case .notAvailable: return PinCode.notAvailable.localized(LAContext().biometryType == .touchID ? "TouchID" : "FaceID")
            case .passcodeNotSet: return PinCode.passcodeNotSet.localized
            case .bioAuthNotEnabled: return PinCode.bioAuthNotEnabled.localized
            case .exit: return PinCode.exit.localized
            }
        }

        var buttonTitle: String {
            switch self {
            case .exit: return PinCode.exitButton.localized
            default: return PinCode.settings.localized
            }
        }

        struct Response {
            let alert: Alert
        }
        struct ViewModel {
            let alert: Alert
        }
    }

    enum Exit {
        struct Request {}
    }

    enum Placeholder {
        struct Response {}
        struct ViewModel {}
    }
}
