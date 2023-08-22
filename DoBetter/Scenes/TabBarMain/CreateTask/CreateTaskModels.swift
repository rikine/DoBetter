//
//  CreateTaskModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 03.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

enum CreateTask {
    enum Table {
        struct Response {
            var endDate: Date?
            var color: TaskModel.Color
            var imageURL: URL?
            var image: UIImage?
            var isImageDeleted: Bool
            var texts: [CommonInputID: String]
            var section: SectionModel
            let type: ActionType
        }
    }

    enum ColorPicker {
        struct Request {
            let color: TaskModel.Color
        }

        struct ViewModel {
            let color: TaskModel.Color
        }
    }

    enum SectionPicker {
        struct Request {
            let section: SectionModel
        }

        struct ViewModel {
            let section: SectionModel
        }
    }

    enum NavigationBar {
        struct ViewModel {
            let type: ActionType
        }
    }

    enum DatePicker: CellModelPayload, Equatable {
        case model(currentDate: Date?)

        struct Request {
            let selectedDate: Date?
        }
    }

    enum Height {
        struct Request {}
    }

    enum ActionType {
        case new, update
    }

    enum Input {
        struct Request {
            let text: String
            let id: CommonInputID
        }
    }

    enum Image {
        struct Request {
            let image: UIImage?
        }
    }

    enum Button {
        struct Request {}
    }

    enum Error: LocalizedError {
        case emptyTitle

        var errorDescription: String? {
            switch self {
            case .emptyTitle: return "Empty title"
            }
        }
    }
}
