//
//  MyFeedModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

enum MyFeed {
    enum Profile {
        struct Request {
            let uid: String?
        }
    }

    enum CreateTask {
        struct Request {}
    }

    enum Task {
        struct Request {
            let model: TaskModel
        }
    }

    struct Filters: Equatable {
        var isOnlyDone: Bool?
        var fromDate: Date?
        var toDate: Date?
        var section: SectionModel?
        var isOnlyInProgress: Bool?
        var toEndDate: Date?
        var fromEndDate: Date?
        var title: String?

        var count: Int? {
            let count = (isOnlyDone != nil).number + (fromDate != nil).number + (toDate != nil).number
                + (section != nil).number + (isOnlyInProgress != nil).number + (toEndDate != nil).number
                + (fromEndDate != nil).number

            return count == 0 ? nil : count
        }

        init() {
            isOnlyDone = nil
            fromDate = nil
            toDate = nil
            section = nil
            isOnlyInProgress = nil
            toEndDate = nil
            fromEndDate = nil
            title = nil
        }

        struct Request {}
    }

    enum Table {
        struct Response {
            let tasks: [TaskModel]
            let shouldShowLoading: Bool
            let withDiffer: Bool
            let loadingDoneIds: [String]
            let loadingLikesIds: [String]
            let filterName: String?
        }
    }

    enum Like {
        struct Request {
            let task: TaskModel
        }
    }

    enum Done {
        struct Request {
            let task: TaskModel
        }
    }

    enum FilterCount {
        struct Response {
            let count: Int?
        }

        struct ViewModel {
            let count: Int?
        }
    }

    enum Delete {
        struct Request {
            let model: TaskModel
        }
    }
}

extension Bool {
    var number: Int { self ? 1 : 0 }
}
