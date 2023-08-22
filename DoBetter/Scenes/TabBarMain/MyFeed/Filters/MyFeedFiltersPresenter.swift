//
//  MyFeedFiltersPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 09.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol MyFeedFiltersPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: MyFeedFilters.Table.Response)
}

class MyFeedFiltersPresenter: MyFeedFiltersPresentationLogic,
                              TablePresenting,
                              PresentingType,
                              Initializable {

    weak var viewController: MyFeedFiltersDisplayLogic?

    var sections: [Table.SectionViewModel] {
        makeSection(for: headlineModel) +
            makeSection(for: isDoneCheckbox) +
            makeSection(for: isInProgressCheckbox) +
            makeSection(for: fromDatePicker) +
            makeSection(for: toDatePicker) +
            makeSection(for: fromEndDatePicker) +
            makeSection(for: toEndDatePicker) +
            makeSection(for: sectionPicker)
    }

    private var headlineModel: BottomSheetHeadlineView.Cell.Model?
    private var fromDatePicker: TextCell.Cell.Model?
    private var toDatePicker: TextCell.Cell.Model?
    private var fromEndDatePicker: TextCell.Cell.Model?
    private var toEndDatePicker: TextCell.Cell.Model?
    private var isDoneCheckbox: CheckboxView.Cell.Model?
    private var isInProgressCheckbox: CheckboxView.Cell.Model?
    private var sectionPicker: TaskSectionPickerView.CollectionFlow?

    required init() {}

    func presentTable(_ response: MyFeedFilters.Table.Response) {
        headlineModel = .init(.init(headline: Localization.MyFeed.filters.localized.attrString,
                                    rightText: Localization.clear.localized.apply(style: .line.accent)))
        fromDatePicker = makeDatePicker(date: response.model.fromDate, payload: .from(response.model.fromDate))
        toDatePicker = makeDatePicker(date: response.model.toDate, payload: .to(response.model.toDate))
        fromEndDatePicker = makeDatePicker(date: response.model.fromEndDate, payload: .fromEnd(response.model.fromEndDate))
        toEndDatePicker = makeDatePicker(date: response.model.toEndDate, payload: .toEnd(response.model.toEndDate))
        sectionPicker = makeSectionPicker(selectedSection: response.model.section)
        isDoneCheckbox = makeCheckbox(isSelected: response.model.isOnlyDone, payload: .done)
        isInProgressCheckbox = makeCheckbox(isSelected: response.model.isOnlyInProgress, payload: .inProgress)

        viewController?.displayTable(.init(sections: sections))
    }

    private func makeDatePicker(date: Date?, payload: MyFeedFilters.DateFilter) -> TextCell.Cell.Model {
        .init(.init(text: date.map(DateFormatter.withDots.string)?.attrString ?? ("00.00.0000").apply(style: .empty.secondary),
                    info: payload.title.attrString.apply(.empty.center), rightButtonV2: Localization.edit.localized.attrString)
                      .payload(payload), padding: .horizontal(16) + .vertical(8))
    }

    private func makeSectionPicker(selectedSection: SectionModel?) -> TaskSectionPickerView.CollectionFlow {
        let items: [TaskSectionPickerView.Model] = SectionModel.allCases.map {
            .init(section: $0, isSelected: $0 == selectedSection)
        }

        return .init(items: items.map { .init($0) },
                     itemSize: .square(40),
                     scrollBehaviour: .plain,
                     isExpandSingleItemEnabled: false,
                     preselectedIndexAlwaysUpdate: false,
                     backgroundColor: .clear,
                     onCellDequeued: { [weak self] cell, index, model in
                         guard let cell = cell as? TaskSectionPickerView.CollectionCell,
                               let model = model as? TaskSectionPickerView.CollectionCell.Model
                         else { return }

                         cell.mainView.onTap {
                             self?.viewController?.displayOnSectionPick(.init(section: model.mainViewModel.section))
                         }
                     })
    }

    private func makeCheckbox(isSelected: Bool?, payload: MyFeedFilters.DoneFilter) -> CheckboxView.Cell.Model {
        .init(.init(text: payload.title.apply(style: .line), isSelected: isSelected).payload(payload),
              padding: .horizontal(16) + .vertical(8))
    }

    private func makeTextCell(info: String) -> TextCell.Cell.Model {
        .init(.init(info: info.apply(style: .empty.center)))
    }

    private func makeSection(for model: CellViewAnyModel?) -> [Table.SectionViewModel] {
        makeSection(for: [model].flatten())
    }

    private func makeSection(for models: [CellViewAnyModel]?) -> [Table.SectionViewModel] {
        guard let models, !models.isEmpty else { return [] }
        return .single(with: models)
    }
}
