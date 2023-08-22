//
//  PhoneCodeEnterModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 11.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

enum PhoneCodeEnter {
    typealias PhoneCode = Localization.PhoneCode

    enum Table {
        struct Response {}
    }

    enum Code {
        struct Request {
            let code: String
        }
    }

    enum Timer {
        enum State {
            case set, remove, skip
        }

        struct Response {
            let state: State
        }

        struct ViewModel {
            let state: State
        }
    }

    enum Error: LocalizedError {
        case emptyCode, codeSent

        var errorDescription: String? {
            switch self {
            case .emptyCode: return PhoneCode.emptyCode.localized
            case .codeSent: return PhoneCode.codeSent.localized
            }
        }
    }

    enum Height {
        struct Request {}
    }

    enum Button {
        case retry, send

        var title: String {
            switch self {
            case .retry: return PhoneCode.retry.localized
            case .send: return PhoneCode.send.localized
            }
        }

        struct Request {
            let button: Button
        }
    }
}
