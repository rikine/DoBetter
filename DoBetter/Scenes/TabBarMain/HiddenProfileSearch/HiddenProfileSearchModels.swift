//
//  HiddenProfileSearchModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

enum HiddenProfileSearch {
    enum Table {
        struct Response {}
    }

    enum Height {
        struct Request {}
    }

    enum Search {
        struct Request {
            let text: String
        }
    }

    enum Button {
        struct Request {}
    }
}
