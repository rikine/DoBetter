//
//  CreateTaskPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 03.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol CreateTaskPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: CreateTask.Table.Response)
}

class CreateTaskPresenter: CreateTaskPresentationLogic,
                           TablePresenting,
                           PresentingType,
                           Initializable {
    typealias Task = Localization.CreateTask

    weak var viewController: CreateTaskDisplayLogic?

    var sections: [Table.SectionViewModel] {
        makeSection(for: headlineModel) +
            makeSection(for: titleModel) +
            makeSection(for: descriptionModel) +
            makeSection(for: datePicker) +
            makeSection(for: colorPicker) +
            makeSection(for: makeTextCell(info: Task.infoColor.localized)) +
            makeSection(for: sectionPicker) +
            makeSection(for: makeTextCell(info: Task.infoSection.localized)) +
            makeSection(for: imageUpload)
    }

    private var headlineModel: BottomSheetHeadlineView.Cell.Model?
    private var titleModel: InputCell.Model?
    private var descriptionModel: TextAreaView.Cell.Model?
    private var imageUpload: UploadImageView.Cell.Model?
    private var colorPicker: ColorPickerView.CollectionFlow?
    private var datePicker: TextCell.Cell.Model?
    private var sectionPicker: TaskSectionPickerView.CollectionFlow?

    required init() {}

    func presentTable(_ response: CreateTask.Table.Response) {
        headlineModel = .init(.init(headline: response.type == .new ? Task.titleCreate.localized.attrString : Task.titleChange.localized.attrString))
        titleModel = makeInput(value: response.texts[.title].emptyLet)
        descriptionModel = makeTextAreaModel(value: response.texts[.description].emptyLet)
        imageUpload = makeUploadModel(url: response.imageURL, isDeleted: response.isImageDeleted, image: response.image)
        colorPicker = makeColorPicker(selected: response.color)
        datePicker = makeDatePicker(date: response.endDate)
        sectionPicker = makeSectionPicker(selectedSection: response.section)

        viewController?.displayTable(.init(sections: sections), withDiffer: false)
    }

    private func makeInput(value: String?) -> InputCell.Model {
        .init(inputModel: .init(inputID: CommonInputID.title,
                                placeholder: Task.namePlaceholder.localized.style(.line.secondary),
                                value: value?.style(.line),
                                info: Task.nameInfo.localized.style(.label.secondary.center),
                                typingAttributes: TextStyle.line.attributes,
                                isEditable: true,
                                maxLength: 100,
                                shouldHighlightOnFocus: true,
                                isPhone: false)).payload(CommonInputID.title)
    }

    private func makeTextAreaModel(value: String?) -> TextAreaView.Cell.Model {
        .init(.init(info: Task.descriptionInfo.localized.style(.label.secondary.center),
                    textViewModel: .textAreaModel(text: (value ?? "").style(.line),
                                                  placeholder: Task.descriptionPlaceholder.localized.style(.line.secondary),
                                                  isEditable: true,
                                                  isScrollEnabled: true,
                                                  typingAttributes: TextStyle.line.attributes),
                    height: 88).payload(CommonInputID.description))
    }

    private func makeUploadModel(url: URL?, isDeleted: Bool, image: UIImage?) -> UploadImageView.Cell.Model {
        let shouldDownloadImage = isDeleted ? false : image == nil
        return .init(.init(image: .init(url: shouldDownloadImage ? url : nil, placeholder: Glyph(image: image).map {
            IconModel(shape: .largeSquircle, glyph: $0).glyphSize(.square(80))
        } ?? .Task.empty.glyphSize(.square(80)), style: .large)))
    }

    private func makeColorPicker(selected color: TaskModel.Color) -> ColorPickerView.CollectionFlow {
        let items: [ColorPickerView.Model] = TaskModel.Color.allCases.map { .init(color: $0, isSelected: $0 == color && color != .none) }

        return .init(items: items.map { .init($0) },
                     itemSize: .square(40),
                     scrollBehaviour: .plain,
                     isExpandSingleItemEnabled: false,
                     preselectedIndexAlwaysUpdate: false,
                     backgroundColor: .clear,
                     onCellDequeued: { [weak self] cell, index, model in
                         guard let cell = cell as? ColorPickerView.CollectionCell, let model = model as? ColorPickerView.CollectionCell.Model else { return }

                         cell.mainView.onTap {
                             self?.viewController?.onColorPick(.init(color: model.mainViewModel.color))
                         }
                     })
    }

    private func makeColorIconModel(from color: TaskModel.Color?) -> IconModel? {
        .init(shape: .mediumSquircle, border: .init(color: .smoke, width: 4), image: (color?.uiColor ?? .constantWhite).asUIImage(), padding: .right(16))
    }

    private func makeDatePicker(date: Date?) -> TextCell.Cell.Model {
        .init(.init(text: date.map(DateFormatter.taskFull.string)?.attrString ?? ("00.00.0000 00:00").apply(style: .empty.secondary),
                    info: Task.endDate.localized.apply(style: .empty.center), rightButtonV2: Localization.edit.localized.attrString)
                      .payload(CreateTask.DatePicker.model(currentDate: date)), padding: .horizontal(16) + .vertical(8))
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
                               let model = model as? TaskSectionPickerView.CollectionCell.Model else { return }

                         cell.mainView.onTap {
                             self?.viewController?.displayOnSectionPick(.init(section: model.mainViewModel.section))
                         }
                     })
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

extension CommonInputID {
    static let title = CommonInputID(rawValue: "title")
}
