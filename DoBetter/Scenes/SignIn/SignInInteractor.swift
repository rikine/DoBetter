//
//  SignInInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

protocol SignInBusinessLogic: TableBusinessLogic, BioAuthBusinessLogic {
    func onInputChange(_ request: SignIn.Input.Request)
    func onButtonTap(_ request: SignIn.Button.Request)
}

class SignInInteractor: SignInBusinessLogic,
                        InteractingType,
                        FlagLoadingType,
                        Initializable,
                        BioAuthInteracting {

    var presenter: SignInPresentationLogic?
    var worker = SignInWorker()
    weak var coordinator: SignInCoordinator?

    var isLoading = false

    private var texts: [CommonInputID: String] = [:]

    private var screenType: SignIn.ScreenType = .email

    required init() {}

    func loadV2(_ request: Common.LoadV2.Request) {
        presentTable()
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onInputChange(_ request: SignIn.Input.Request) {
        texts[request.type] = request.text
    }

    func onButtonTap(_ request: SignIn.Button.Request) {
        switch request.button {
        case .continue: onSignIn()
        case .signUp: coordinator?.showSignUp(screenType: .email)
        case .signWithPhone: presentTable(with: .phone)
        case .signWithEmail: presentTable(with: .email)
        case .signWithGoogle: onGoogleSign()
        }
    }

    private func presentTable(with type: SignIn.ScreenType? = nil) {
        screenType = type ?? screenType
        presenter?.presentTable(.init(screen: type ?? screenType))
    }

    private func onSignIn() {
        switch screenType {
        case .email: onEmailSign()
        case .phone: onPhoneSign()
        }
    }

    private func onEmailSign() {
        guard !isLoading else { return }

        let email = texts[.email] ?? ""
        let password = texts[.password] ?? ""
        do {
            try SignModelPresenter.check(email: email, password: password)
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
            return
        }

        startLoading(with: .initial)
        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await self.worker.signIn(email: email, password: password)
                self.presenter?.presentBioAuthAlert(.init())
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
            }

            self.finishLoading()
        }
    }

    private func onPhoneSign() {
        guard !isLoading else { return }

        let phone = "+" + String(texts[.phone]?.filter { $0.isNumber } ?? [])

        do {
            try SignModelPresenter.check(phone: phone)
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
            return
        }

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                guard try await self.worker.checkPhoneExists(phone: phone).isExists else {
                    throw SignModelPresenter.Error.phoneNumberNotExists
                }
                self.showCodeEnter(phone)
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
                return
            }
        }
    }

    private func showCodeEnter(_ phone: String) {
        coordinator?.showCodeEnter(phone: phone) { [weak self] isSuccess in
            guard isSuccess else { return }
            self?.presenter?.presentBioAuthAlert(.init())
        }
    }

    private func onGoogleSign() {
        guard !isLoading else { return }
        guard let vc = coordinator?.root.viewController else { return }

        startLoading(with: .initial)
        Task { @MainActor [weak self] in
            do {
                try await self?.worker.signInWithGoogle(on: vc)
                self?.presenter?.presentBioAuthAlert(.init())
            } catch {
                self?.presenter?.presentError(.init(error: error, type: .banner))
            }

            self?.finishLoading()
        }
    }
}
