//
//  ProfileEditPresenter.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol ProfileEditPresentationLogic: TablePresentationLogic {
    func presentTable(_ response: ProfileEdit.Table.Response)
}

class ProfileEditPresenter: ProfileEditPresentationLogic,
                                         TablePresenting,
                                         PresentingType,
                                         Initializable {

    weak var viewController: ProfileEditDisplayLogic?
    
    var sections: [Table.SectionViewModel] {
        .single(with: allModels)
    }

    private var allModels: [CellViewAnyModel] = []

    required init() {}

    func presentTable(_ response: ProfileEdit.Table.Response) {
        allModels.removeAll(keepingCapacity: true)

        allModels.append(makeUploadModel(model: response.profile, isDeleted: response.isDeleted, image: response.image))
        allModels.append(makeInputModel(.name, value: response.texts[.name].emptyLet))
        allModels.append(makeInputModel(.nickname, value: response.texts[.nickname].emptyLet))
        allModels.append(makeInputModel(.description, value: response.texts[.description].emptyLet))

        viewController?.displayTable(.init(sections: sections), withDiffer: response.withDiffer)
    }

    private func makeInputModel(_ input: ProfileEdit.Input, value: String?) -> CellViewAnyModel {
        switch input.cellType {
        case .input: return Self.makeInputCell(inputID: input.inputID, value: value, placeholder: input.placeholder, info: input.info)
        case .textArea: return Self.makeTextAreaModel(input, value: value)
        }
    }

    private func makeUploadModel(model: ProfileModel, isDeleted: Bool, image: UIImage?) -> UploadImageView.Cell.Model {
        let shouldDownloadImage = isDeleted ? false : image == nil
        return .init(.init(image: .init(url: shouldDownloadImage ? model.photoUrl : nil, placeholder: Glyph(image: image).map {
            IconModel(shape: .largeSquircle, glyph: $0).glyphSize(.square(80))
        } ?? model.initialsImage(), style: .large)))
    }

    static func makeInputCell(inputID: CommonInputID, value: String?,
                              placeholder: String, info: String) -> InputCell.Model {
        .init(inputModel: .init(inputID: inputID,
                                placeholder: placeholder.style(.line.secondary),
                                value: value?.style(.line),
                                info: info.style(.label.secondary.center),
                                typingAttributes: TextStyle.line.attributes,
                                isEditable: true,
                                maxLength: 100,
                                shouldHighlightOnFocus: true,
                                isPhone: false), payload: inputID)
    }

    static func makeTextAreaModel(_ input: ProfileEdit.Input, value: String?) -> TextAreaView.Cell.Model {
        .init(.init(info: input.info.style(.label.secondary.center),
                    textViewModel: .textAreaModel(text: (value ?? "").style(.line),
                                                  placeholder: input.placeholder.style(.line.secondary),
                                                  isEditable: true,
                                                  isScrollEnabled: true,
                                                  typingAttributes: TextStyle.line.attributes),
                    height: 88).payload(input.inputID))
    }
}

extension CommonInputID: CellModelPayload {
    static let description = CommonInputID(rawValue: "Description")
    static let name = CommonInputID(rawValue: "Name")
}

extension Optional where Wrapped == String {
    var emptyLet: String? {
        switch self {
        case .some(let string): return string.isEmpty ? nil : string
        case .none: return nil
        }
    }
}
