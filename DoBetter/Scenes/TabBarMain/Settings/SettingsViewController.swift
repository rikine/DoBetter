//
//  SettingsViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 16.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes

protocol SettingsDisplayLogic: TableDisplayLogic {
    func displayBioAuthAlert(_ response: BioAuth.Suggest.Response)
}

class SettingsViewController: TableViewNodeController,
                              SettingsDisplayLogic,
                              TableDisplaying,
                              SnackNotificationDisplayer {

    typealias Strings = Localization.Settings

    weak var interactor: SettingsBusinessLogic?
    override var cellModelTypes: [CellViewAnyModel.Type] {
        [SettingView.Cell.Model.self]
    }
    override var isBottomViewNeeded: Bool { true }
    // MARK: View lifecycle

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.title.localized

        interactor?.loadV2(.initial)
    }

    override func refresh() {
        super.refresh()
        interactor?.loadV2(.pullToRefresh)
    }

    override func makeBottomView() -> View {
        let stack = ButtonBarStack()
        ButtonBarStack.Model(buttons: [.init(text: Localization.Settings.exit.localized, style: .secondaryNegative) { [weak self] in
            self?.showConfirmExit()
        }]).setup(view: stack)

        return stack
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as SettingView.Cell, var model as SettingView.Cell.Model):
            cell.mainView.switcher.onTap { [weak self] in
                model.mainViewModel.isSwitcherOn = !model.mainViewModel.isSwitcherOn
                self?.sections[indexPath] = model

                self?.interactor?.didSelectRow(.init(indexPath: indexPath, payload: model.payload))
            }
        default: break
        }
    }

    func displayBioAuthAlert(_ response: BioAuth.Suggest.Response) {
        let alert = UIAlertController(title: Strings.disableBioTitle.localized,
                                      message: Strings.disableBioSubtitle.localized,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: Localization.ok.localized, style: .default) { [weak interactor] _ in
            interactor?.onBioAuth(.init(isCanceled: false))
        })
        alert.addAction(.init(title: Localization.cancel.localized, style: .destructive) { [weak interactor] _ in
            interactor?.onBioAuth(.init(isCanceled: true))
        })

        present(alert, animated: true)
    }

    private func showConfirmExit() {
        let alert = standardAlert(title: Strings.confirmExitTitle.localized,
                                  message: Strings.confirmExitSubtitle.localized,
                                  cancelTitle: Localization.cancel.localized,
                                  actionTitle: Strings.exit.localized) { [weak interactor] in
            interactor?.exit(.init())
        }

        present(alert, animated: true)
    }
}
