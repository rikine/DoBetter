//
//  TaskModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 18.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

enum TaskModels {
    enum Table {
        struct Response {
            let task: TaskModel
            let user: ProfileModel?
            let isLikeLoading: Bool
        }
    }

    enum BackgroundColor {
        struct ViewModel {
            let color: UIColor
        }
    }

    enum Slider {
        struct ViewModel {
            let title: String
        }
    }

    enum Edit {
        struct Request {}
    }

    enum Remove {
        struct Request {}
    }

    enum Done {
        struct Request {}
    }

    enum Editable {
        struct ViewModel {
            let isEditable: Bool
        }
    }

    enum Profile {
        struct Request { }
    }

    enum Likes {
        struct ViewModel {
            let count: String
            let status: String
            let isLiked: Bool
            let isLikeLoading: Bool
        }

        struct Request {}
    }
}
