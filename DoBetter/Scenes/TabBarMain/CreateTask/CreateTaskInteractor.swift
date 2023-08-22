//
//  CreateTaskInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 03.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol CreateTaskBusinessLogic: TableBusinessLogic {
    func updateHeight(_ request: CreateTask.Height.Request)
    func onImageEdited(_ request: CreateTask.Image.Request)
    func onInputEdited(_ request: CreateTask.Input.Request)
    func onSave(_ request: CreateTask.Button.Request)
    func onColorPick(_ request: CreateTask.ColorPicker.Request)
    func onSectionPick(_ request: CreateTask.SectionPicker.Request)
    func onDatePick(_ request: CreateTask.DatePicker.Request)
}

class CreateTaskInteractor: CreateTaskBusinessLogic,
                            InteractingType,
                            FlagLoadingType {

    var presenter: CreateTaskPresentationLogic?
    var worker = CreateTaskWorker()
    weak var coordinator: CreateTaskCoordinator?

    var isLoading = false

    private var response: CreateTask.Table.Response

    private var model: TaskModel?

    private let type: CreateTask.ActionType

    required init(model: TaskModel?, type: CreateTask.ActionType) {
        self.type = type
        self.model = model

        response = .init(endDate: model?.endDate,
                         color: model?.color ?? .none,
                         imageURL: model?.imageUrl,
                         image: nil,
                         isImageDeleted: false,
                         texts: Self.makeParameters([.description: model?.description, .title: model?.title]),
                         section: model?.section ?? .none,
                         type: type)
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        presenter?.presentTable(response)
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func updateHeight(_ request: CreateTask.Height.Request) {
        coordinator?.updateHeight()
    }

    func onImageEdited(_ request: CreateTask.Image.Request) {
        response.image = request.image
        response.isImageDeleted = request.image == nil
        loadV2(.force)
    }

    func onInputEdited(_ request: CreateTask.Input.Request) {
        response.texts[request.id] = request.text.removingLeadingSpaces()
        loadV2(.soft)
    }

    func onColorPick(_ request: CreateTask.ColorPicker.Request) {
        response.color = request.color
        loadV2(.force)
    }

    func onSectionPick(_ request: CreateTask.SectionPicker.Request) {
        response.section = request.section
        loadV2(.force)
    }

    func onDatePick(_ request: CreateTask.DatePicker.Request) {
        response.endDate = request.selectedDate
        loadV2(.force)
    }

    static func makeParameters(_ sourceDict: [CommonInputID: String?]) -> [CommonInputID: String] {
        let nonNilDict = sourceDict.compactMapValues { $0 }
        guard !nonNilDict.isEmpty else { return [:] }
        return nonNilDict
    }

    func onSave(_ request: CreateTask.Button.Request) {
        guard !isLoading else { return }

        let texts = response.texts

        guard let title = texts[.title].emptyLet else {
            presenter?.presentError(.init(error: CreateTask.Error.emptyTitle, type: .banner))
            return
        }

        startLoading(with: .initial)
        Task { @MainActor in
            do {
                try await worker.createOrUpdateTask(taskId: model?.uid,
                                                    title: title,
                                                    description: texts[.description].emptyLet,
                                                    endDate: response.endDate,
                                                    section: response.section,
                                                    color: response.color,
                                                    image: response.image,
                                                    shouldRemoveImage: response.isImageDeleted)
                self.coordinator?.stop()
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            finishLoading()
        }
    }
}
