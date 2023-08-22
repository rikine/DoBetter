//
//  HiddenProfileSearchInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

protocol HiddenProfileSearchBusinessLogic: TableBusinessLogic {
    func onInputChanged(_ request: HiddenProfileSearch.Search.Request)
    func changeHeight(_ request: HiddenProfileSearch.Height.Request)
    func onSearch(_ request: HiddenProfileSearch.Button.Request)
}

class HiddenProfileSearchInteractor: HiddenProfileSearchBusinessLogic,
                                     InteractingType,
                                     FlagLoadingType,
                                     Initializable {

    var presenter: HiddenProfileSearchPresentationLogic?
    var worker = HiddenProfileSearchWorker()
    weak var coordinator: HiddenProfileSearchCoordinator?

    var isLoading = false

    private var nickname = ""

    required init() {}

    func loadV2(_ request: Common.LoadV2.Request) {
        presenter?.presentTable(.init())
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onInputChanged(_ request: HiddenProfileSearch.Search.Request) {
        nickname = request.text
    }

    func changeHeight(_ request: HiddenProfileSearch.Height.Request) {
        coordinator?.changeHeight()
    }

    func onSearch(_ request: HiddenProfileSearch.Button.Request) {
        guard !isLoading else { return }
        startLoading(with: .initial, message: "Поиск...".style(.line.multiline))

        Task { @MainActor in
            do {
                let profile = try await worker.fetchUser(with: nickname)
                coordinator?.stop(withSuccess: profile)
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            finishLoading()
        }
    }
}
