//
//  SettingsModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 16.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

enum Settings {
    typealias Strings = Localization.Settings

    enum Table {
        struct Response {
            let isFaceIDEnabled: Bool
            let isSecureProfileEnabled: Bool
        }
    }

    enum Setting: CellModelPayload, Equatable {
        case secure, bioAuth

        var title: String {
            switch self {
            case .bioAuth: return Strings.bioAuth.localized
            case .secure: return Strings.secure.localized
            }
        }
    }

    enum Exit {
        struct Request {}
    }
}
