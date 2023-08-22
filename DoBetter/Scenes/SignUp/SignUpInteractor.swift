//
//  SignUpInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 07.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import Foundation

protocol SignUpBusinessLogic: TableBusinessLogic, BioAuthBusinessLogic {
    func onInputChange(_ request: SignUp.Input.Request)
    func onButtonTap(_ request: SignUp.Button.Request)
}

class SignUpInteractor: SignUpBusinessLogic,
                        InteractingType,
                        FlagLoadingType,
                        BioAuthInteracting {

    var presenter: SignUpPresentationLogic?
    var worker = SignUpWorker()
    weak var coordinator: SignUpCoordinator?

    var isLoading = false

    private var texts: [CommonInputID: String] = [:]

    private var screenType: SignUp.ScreenType

    required init(screenType: SignUp.ScreenType) {
        self.screenType = screenType
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        presentTable()
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onInputChange(_ request: SignUp.Input.Request) {
        texts[request.type] = request.text
    }

    func onButtonTap(_ request: SignUp.Button.Request) {
        switch request.button {
        case .signIn: coordinator?.showSignIn()
        case .continue:
            switch screenType {
            case .email: onSignUp()
            case .phone: onPhoneSignUp()
            }
        case .signWithPhone: presentTable(with: .phone)
        case .signWithEmail: presentTable(with: .email)
        }
    }

    private func presentTable(with type: SignUp.ScreenType? = nil) {
        screenType = type ?? screenType
        presenter?.presentTable(.init(screenType: type ?? screenType))
    }

    private func onPhoneSignUp() {
        guard !isLoading else { return }
        let nick = texts[.nickname] ?? ""
        let phone = "+" + String(texts[.phone]?.filter { $0.isNumber } ?? [])
        do {
            try SignModelPresenter.check(nickname: nick, phone: phone)
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
            return
        }

        Task { @MainActor in
            do {
                try await worker.checkPhoneExists(phone: phone)
                try await worker.checkNicknameExists(nickname: nick)
                self.showCodeEnter(nickname: nick, phone)
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
                return
            }
        }
    }

    private func showCodeEnter(nickname: String, _ phone: String) {
        coordinator?.showCodeEnter(nickname: nickname, phone: phone) { [weak self] isSuccess in
            guard isSuccess else { return }
            self?.presenter?.presentBioAuthAlert(.init())
        }
    }

    private func onSignUp() {
        guard !isLoading else { return }

        let nick = texts[.nickname] ?? ""
        let email = texts[.email] ?? ""
        let password = texts[.password] ?? ""
        let passwordReenter = texts[.passwordReenter] ?? ""

        do {
            try SignModelPresenter.check(nickname: nick, email: email, password: password, reenteredPassword: passwordReenter)
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
            return
        }

        startLoading(with: .initial)

        Task { @MainActor in
            do {
                try await worker.checkNicknameExists(nickname: nick)
                try await worker.signUp(nickname: nick, email: email, password: password)
                presenter?.presentBioAuthAlert(.init())
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            finishLoading()
        }
    }
}
