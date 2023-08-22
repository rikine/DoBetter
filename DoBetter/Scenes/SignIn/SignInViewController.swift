//
//  SignInViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes

protocol SignInDisplayLogic: TableDisplayLogic, BioAuthDisplayLogic {
    func displayOnButtonTap(_ viewModel: SignIn.Button.ViewModel)
}

class SignInViewController: TableViewNodeController,
                            SignInDisplayLogic,
                            TableDisplaying,
                            NavigationBarHiding,
                            KeyboardObservableTable,
                            SnackNotificationDisplayer,
                            BioAuthDisplaying {
    var interactor: SignInBusinessLogic?

    override var cellModelTypes: [CellViewAnyModel.Type] {
        [InputCell.Model.self, ButtonBarStack.Cell.Model.self]
    }
    override var isRefreshControlNeeded: Bool { false }
    override var additionalTopContentInset: CGFloat { 16 }
    var prefersNavigationBarHidden: Bool { false }
    override var isBottomViewNeeded: Bool { true }

    var keyboardObserver: KeyboardObserver = .init()

    // MARK: View lifecycle

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.SignIn.title.localized
        hideKeyboardWhenTappedAround()
        observeKeyboardAndOffsetRootView()
        extendedLayoutIncludesOpaqueBars = true

        interactor?.loadV2(.initial)

        let agreementText: AttrString = "\(Localization.Sign.agreement1.localized) \(Localization.Sign.agreement2.localized, .empty.accent)"
        (bottomView as? Text)?.text(agreementText.apply(.label.center.multiline.secondary))
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as InputCell, let model as InputCell.Model):
            cell.input.didChange = { [weak self] field in
                guard let type = model.inputModel.inputID.base as? CommonInputID else {
                    return guardUnreachable()
                }
                self?.interactor?.onInputChange(.init(text: field.text ?? "", type: type))
                self?.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }

            cell.input.onReturn = { [weak self] _ in
                guard let nextIndexPath = self?.tableView.nextIndexPath(from: indexPath),
                      let responderCell = self?.tableView.cellForRow(at: nextIndexPath) as? ResponderCell,
                      responderCell.isEditingAllowed
                else {
                    cell.input.keyboardFocus(false)
                    return
                }
                responderCell.makeCellFirstResponder()
            }
        default:
            break
        }
    }

    func displayOnButtonTap(_ viewModel: SignIn.Button.ViewModel) {
        view.endEditing(true)
        interactor?.onButtonTap(.init(button: viewModel.button))
    }

    func onKeyboard() {
        guard let height = keyboardObserver.lastPayload?.trueKeyboardHeight else { return }
        bottomViewStack?.hidden(height != 0)
    }

    override func makeBottomView() -> View {
        Text().padding(.horizontal(16)).onTap { [weak self] in
            self?.view?.endEditing(true)
            UIApplication.shared.open(.init(string: "https://dobetterbackend-1-q9170668.deta.app/v1/image?name=PrivacyPolicyDo-Better.pdf")!)
        }
    }
}
