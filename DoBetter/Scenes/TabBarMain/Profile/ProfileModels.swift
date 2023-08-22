//
//  ProfileModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

enum Profile {
    enum Table {
        struct Response {
            let model: ProfileModel
            let isLoading: Bool
        }
    }

    enum Headline: CellModelPayload {
        case tasks, followings, followers
    }

    enum Button {
        case edit, follow, user(model: ProfileModel), task(model: TaskModel),
             allFollowings, allFollowers, allTasks, doneTask(model: TaskModel),
             likeTask(model: TaskModel)
        case settings

        typealias Request = Button

        typealias ViewModel = Button
    }

    enum NavBar {
        struct ViewModel {
            let title: String
            let isEditable: Bool
        }
    }

    enum Tasks {
        struct Response {
            let tasks: [TaskModel]
            let isLoadingDoneUIds: [String]
            let isLoadingLikeUIds: [String]
        }
    }

    enum Users {
        struct Response {
            let followers: [ProfileModel]
            let following: [ProfileModel]
        }
    }

    enum Statistics {
        struct Response {
            let statistics: StatisticsModel
        }
    }
}
