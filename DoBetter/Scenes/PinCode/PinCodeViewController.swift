//
//  PinCodeViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes

protocol PinCodeDisplayLogic: TableDisplayLogic {
    func displayAlert(_ response: PinCode.Alert.ViewModel)
    func displayPlaceholder(_ response: PinCode.Placeholder.ViewModel)
}

class PinCodeViewController: TableViewNodeController,
                             PinCodeDisplayLogic,
                             TableDisplaying {
    typealias PinCodeString = Localization.PinCode

    var interactor: PinCodeBusinessLogic?

    override var isRefreshControlNeeded: Bool { false }
    override var isCustomHeadlineView: Bool { true }

    // MARK: View lifecycle

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false

        tableView.backgroundView = TableStopperViewModel(.sorry, background: .clear,
                                                         buttonBarModel: .init(buttons: [.init(text: PinCodeString.tryAgain.localized) { [weak self] in
                                                             self?.interactor?.tryToAuth(.init())
                                                         }]),
                                                         stickedToTop: true ~~~ false,
                                                         stopperPadding: .bottom(UIScreen.main.homeIndicatorInset),
                                                         imageSize: .square(156 ~~~ 256),
                                                         imageContentMode: .scaleAspectFit)
                .makeView()
        (tableView.backgroundView as? TableStopper)?.hidden(true)
        return tableView
    }

    override func makeHeadlineView() -> View {
        let width = min(300, UIScreen.main.bounds.width - (32 * 2))
        let height = width / 3
        return Image().width(.fill).padding(.horizontal(32 ~~ 64))
                .icon(.init(glyph: .logo.changeGlyphSize(size: .init(width: width, height: height))))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = PinCodeString.title.localized
        interactor?.loadV2(.initial)
    }

    override func viewDidAppear(animated: Bool, firstTime: Bool) {
        super.viewDidAppear(animated: animated, firstTime: firstTime)
        if firstTime {
            interactor?.tryToAuth(.init())
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headlineView.padding(.top(view.safeAreaInsets.top + 32))
        adjustTableView()
        (tableView.backgroundView as? TableStopper)?
                .padding(.top(tableView.contentInset.top) + .bottom(view.safeAreaInsets.bottom))
    }

    func displayAlert(_ response: PinCode.Alert.ViewModel) {
        let alert = UIAlertController(title: response.alert.title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: response.alert.buttonTitle, style: .destructive) { [weak self] _ in
            guard response.alert != .exit else {
                self?.interactor?.exit(.init())
                return
            }

            let application = UIApplication.shared
            let settingsURL = UIApplication.openSettingsURLString

            if let url = URL(string: settingsURL), application.canOpenURL(url) {
                application.open(url)
            } else {
                self?.displayPlaceholder(.init())
            }
        })
        alert.addAction(.init(title: Localization.cancel.localized, style: .default))
        alert.preferredAction = alert.actions.first
        present(alert, animated: true)
    }

    func displayPlaceholder(_ response: PinCode.Placeholder.ViewModel) {
        (tableView.backgroundView as? TableStopper)?.hidden(false)
    }
}

precedencegroup SmallScreenPrecedence {
    associativity: left
    higherThan: BigScreenPrecedence
}

precedencegroup BigScreenPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator ~~: SmallScreenPrecedence

func ~~<T>(lhs: T, rhs: T) -> T {
    UIScreen.main.isSmall() ? lhs : rhs
}

infix operator ~~~: BigScreenPrecedence

func ~~~<T>(lhs: T, rhs: T) -> T {
    UIScreen.main.isBig() ? rhs : lhs
}
