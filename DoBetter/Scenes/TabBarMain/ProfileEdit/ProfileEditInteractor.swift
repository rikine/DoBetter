//
//  ProfileEditInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit

protocol ProfileEditBusinessLogic: TableBusinessLogic {
    func onTextEdited(_ request: ProfileEdit.Input.Request)
    func onImageEdited(_ request: ProfileEdit.Image.Request)
    func save(_ request: ProfileEdit.Save.Request)
}

class ProfileEditInteractor: ProfileEditBusinessLogic,
                             InteractingType,
                             FlagLoadingType {

    var presenter: ProfileEditPresentationLogic?
    var worker = ProfileEditWorker()
    weak var coordinator: ProfileEditCoordinator?

    var isLoading = false

    private var texts: [CommonInputID: String] = [:]
    private var image: UIImage? = nil
    private var imageDeleted = false

    private let profile: ProfileModel

    required init(profile: ProfileModel) {
        self.profile = profile

        texts[.name] = profile.name
        texts[.nickname] = profile.nickname.removingPrefix("@")
        texts[.description] = profile.description
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        presenter?.presentTable(.init(profile: profile, isDeleted: imageDeleted, image: image,
                                      texts: texts, withDiffer: request == .soft))
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onTextEdited(_ request: ProfileEdit.Input.Request) {
        texts[request.id] = request.text.removingLeadingSpaces()
        loadV2(.soft)
    }

    func onImageEdited(_ request: ProfileEdit.Image.Request) {
        image = request.image
        imageDeleted = request.image == nil
        loadV2(.force)
    }

    func save(_ request: ProfileEdit.Save.Request) {
        guard !isLoading else { return }
        guard let nickname = texts[.nickname].emptyLet?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            presenter?.presentError(.init(error: ProfileEdit.Error.emptyNickname, type: .banner))
            return
        }
        guard nickname.matches(regex: .nicknameRegex) else {
            presenter?.presentError(.init(error: SignModelPresenter.Error.incorrectNickName, type: .banner))
            return
        }

        startLoading(with: .initial)

        Task { @MainActor in
            do {
                try await self.worker.updateProfile(nickname: nickname,
                                                    name: self.texts[.name].emptyLet?.trimmingCharacters(in: .whitespacesAndNewlines),
                                                    description: self.texts[.description].emptyLet?.trimmingCharacters(in: .whitespacesAndNewlines),
                                                    image: self.image,
                                                    shouldRemoveImage: self.imageDeleted)

                self.coordinator?.showProfile()
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
            }

            self.finishLoading()
        }
    }
}

extension String {
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[index...])
    }
}
