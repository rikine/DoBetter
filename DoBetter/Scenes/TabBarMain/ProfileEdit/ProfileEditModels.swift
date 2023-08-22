//
//  ProfileEditModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

enum ProfileEdit {
    typealias Edit = Localization.Profile.Edit

    enum Image {
        struct Request {
            let image: UIImage?
        }
    }

    enum Input {
        enum Cell { case input, textArea }

        case name, nickname, description

        var info: String {
            switch self {
            case .name: return Edit.nameInfo.localized
            case .nickname: return Edit.nicknameInfo.localized
            case .description: return Edit.descriptionInfo.localized
            }
        }

        var placeholder: String {
            switch self {
            case .name: return Edit.namePlaceholder.localized
            case .nickname: return Edit.nicknamePlaceholder.localized
            case .description: return Edit.descriptionPlaceholder.localized
            }
        }

        var inputID: CommonInputID {
            switch self {
            case .name: return .name
            case .nickname: return .nickname
            case .description: return .description
            }
        }

        var cellType: Cell {
            self == .description ? .textArea : .input
        }

        struct Request {
            let text: String
            let id: CommonInputID
        }
    }

    enum Table {
        struct Response {
            let profile: ProfileModel

            let isDeleted: Bool
            let image: UIImage?
            let texts: [CommonInputID: String]
            let withDiffer: Bool
        }
    }

    enum Save {
        struct Request {}
    }

    enum Error: LocalizedError {
        case emptyNickname

        var errorDescription: String? { Edit.emptyNickname.localized }
    }
}
