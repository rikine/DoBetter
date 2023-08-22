//
//  MyFeedFiltersInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 09.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

protocol MyFeedFiltersBusinessLogic: TableBusinessLogic {
    func doneFilter(_ request: MyFeedFilters.DoneFilter.Request)
    func onSectionPick(_ request: MyFeedFilters.SectionFilter.Request)
    func onDatePick(_ request: MyFeedFilters.DateFilter.Request)
    func changeHeight(_ request: MyFeedFilters.Height.Request)
    func onSave(_ request: MyFeedFilters.Save.Request)
    func clear(_ request: MyFeedFilters.Clear.Request)
}

class MyFeedFiltersInteractor: MyFeedFiltersBusinessLogic,
                               InteractingType,
                               FlagLoadingType {

    var presenter: MyFeedFiltersPresentationLogic?
    weak var coordinator: MyFeedFiltersCoordinator?

    var isLoading = false

    private var model: MyFeed.Filters

    required init(model: MyFeed.Filters) {
        self.model = model
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        presenter?.presentTable(.init(model: model))
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func doneFilter(_ request: MyFeedFilters.DoneFilter.Request) {
        switch request.filter {
        case .done:
            switch model.isOnlyDone {
            case true: model.isOnlyDone = false
            case false: model.isOnlyDone = nil
            default: model.isOnlyDone = true
            }
        case .inProgress:
            switch model.isOnlyInProgress {
            case true: model.isOnlyInProgress = false
            case false: model.isOnlyInProgress = nil
            default: model.isOnlyInProgress = true
            }
        }

        loadV2(.initial)
    }

    func onSectionPick(_ request: MyFeedFilters.SectionFilter.Request) {
        if request.section == model.section {
            model.section = nil
        } else {
            model.section = request.section
        }

        loadV2(.initial)
    }

    func onDatePick(_ request: MyFeedFilters.DateFilter.Request) {
        switch request.type {
        case .to: model.toDate = request.selectedDate?.endOfDay
        case .from: model.fromDate = request.selectedDate?.beginningOfDay
        case .toEnd: model.toEndDate = request.selectedDate?.endOfDay
        case .fromEnd: model.fromEndDate = request.selectedDate?.beginningOfDay
        }

        loadV2(.initial)
    }

    func changeHeight(_ request: MyFeedFilters.Height.Request) {
        coordinator?.updateHeight()
    }

    func onSave(_ request: MyFeedFilters.Save.Request) {
        coordinator?.model = model
        coordinator?.stop()
    }

    func clear(_ request: MyFeedFilters.Clear.Request) {
        model = .init()
        loadV2(.initial)
    }
}

extension Date {
    var beginningOfDay: Date {
        Calendar.current.date(from: Calendar.current.dateComponentsInServerTimezone([.year, .month, .day], from: self))!
    }

    var endOfDay: Date { Calendar.current.date(byAdding: DateComponents(second: -1), to: nextDay)! }

    var nextDay: Date { Calendar.current.date(byAdding: DateComponents(day: 1), to: beginningOfDay)! }
}

extension Calendar {
    func dateComponentsInServerTimezone(_ components: Set<Calendar.Component>, from start: Date)
        -> DateComponents {
        var components: DateComponents = dateComponents(components, from: start)
        components.timeZone = .serverTimeZone
        return components
    }
}
