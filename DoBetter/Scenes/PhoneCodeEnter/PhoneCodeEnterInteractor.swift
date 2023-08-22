//
//  PhoneCodeEnterInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 11.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

protocol PhoneCodeEnterBusinessLogic: TableBusinessLogic {
    func onButtonTap(_ request: PhoneCodeEnter.Button.Request)
    func onCodeChanged(_ request: PhoneCodeEnter.Code.Request)
    func changeHeight(_ request: PhoneCodeEnter.Height.Request)
}

class PhoneCodeEnterInteractor: PhoneCodeEnterBusinessLogic,
                                InteractingType,
                                FlagLoadingType {
    var presenter: PhoneCodeEnterPresentationLogic?
    var worker = PhoneCodeEnterWorker()
    weak var coordinator: PhoneCodeEnterCoordinator?

    var isLoading = false

    private var code: String = ""
    private let phone: String
    private let nickname: String?

    init(phone: String, nickname: String?) {
        self.phone = phone
        self.nickname = nickname
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        presenter?.presentTable(.init())
        send(to: phone)
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onButtonTap(_ request: PhoneCodeEnter.Button.Request) {
        switch request.button {
        case .retry: send(to: phone)
        case .send: send(code)
        }
    }

    func onCodeChanged(_ request: PhoneCodeEnter.Code.Request) {
        code = request.code
    }

    func changeHeight(_ request: PhoneCodeEnter.Height.Request) {
        coordinator?.changeHeight()
    }

    private func send(to phone: String) {
        guard !isLoading else { return }
        isLoading = true
        presenter?.presentActivityIndication(.init(isShown: true,
                                                   immediately: true,
                                                   ignoreRefreshControl: true,
                                                   message: Localization.PhoneCode.sendingVerification.localized.style(.line.multiline)))

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await self.worker.signIn(number: phone)
                self.presenter?.presentTimer(.init(state: .set))
                self.presenter?.presentError(.init(error: PhoneCodeEnter.Error.codeSent, type: .banner))
            } catch {
                self.presenter?.presentTimer(.init(state: .skip))
                self.presenter?.presentError(.init(error: error, type: .banner))
            }

            self.finishLoading()
        }
    }

    private func send(_ code: String) {
        guard !isLoading else { return }
        guard !code.isEmpty else {
            presenter?.presentError(.init(error: PhoneCodeEnter.Error.emptyCode, type: .banner))
            return
        }
        isLoading = true
        presenter?.presentActivityIndication(.init(isShown: true,
                                                   immediately: true,
                                                   ignoreRefreshControl: true,
                                                   message: Localization.PhoneCode.checkingVerification.localized.style(.line.multiline)))

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await self.worker.sendCode(nickname: self.nickname, code: code)
                self.coordinator?.stop(withSuccess: true)
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
            }

            self.finishLoading()
        }
    }
}
