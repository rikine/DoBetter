//
//  SearchFollowingsModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

enum SearchFollowings {
    enum SearchType {
        case all, followers, followings
    }

    enum Table {
        struct Response {
            let users: [ProfileModel]
            let shouldShowLoading: Bool
            let withDiffer: Bool
            let updatingProfilesIds: [String]
            let searchText: String?
        }
    }

    enum Follow {
        struct ViewModel {
            let user: ProfileModel
        }

        struct Request {
            let user: ProfileModel
        }
    }

    enum Search {
        struct Request {
            let text: String?
        }
    }

    enum User {
        struct Request {
            let user: ProfileModel
        }
    }

    enum NavBar {
        struct Response {}

        struct ViewModel {}
    }

    enum SearchHidden {
        struct Request {}
    }
}
