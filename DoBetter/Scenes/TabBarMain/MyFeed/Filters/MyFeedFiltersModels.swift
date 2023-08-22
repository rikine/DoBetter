//
//  MyFeedFiltersModels.swift
//  DoBetter
//
//  Created by Никита Шестаков on 09.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

enum MyFeedFilters {
    typealias Filters = Localization.MyFeed.Filters

    enum Table {
        struct Response {
            let model: MyFeed.Filters
        }
    }

    enum DateFilter: CellModelPayload, Equatable {
        case to(Date?), from(Date?), toEnd(Date?), fromEnd(Date?)

        var title: String {
            switch self {
            case .to: return Filters.dateTo.localized
            case .from: return Filters.dateFrom.localized
            case .toEnd: return Filters.endDateTo.localized
            case .fromEnd: return Filters.endDateFrom.localized
            }
        }

        struct Request {
            let selectedDate: Date?
            let type: DateFilter
        }
    }

    enum SectionFilter {
        struct Request {
            let section: SectionModel
        }
    }

    enum DoneFilter: CellModelPayload, Equatable {
        case inProgress, done

        var title: String {
            switch self {
            case .inProgress: return Filters.onlyInProgress.localized
            case .done: return Filters.onlyDone.localized
            }
        }

        struct Request {
            let filter: DoneFilter
        }
    }

    enum Height {
        struct Request {}
    }

    enum Save {
        struct Request {}
    }

    enum Clear {
        struct Request {}
    }
}
