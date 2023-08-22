//
//  HiddenProfileSearchViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes
import SPStorkController

protocol HiddenProfileSearchDisplayLogic: TableDisplayLogic {}

class HiddenProfileSearchViewController: TableViewNodeController,
                                         HiddenProfileSearchDisplayLogic,
                                         TableDisplaying {

    var interactor: HiddenProfileSearchBusinessLogic?

    override var cellModelTypes: [CellViewAnyModel.Type] { [InputCell.Model.self] }
    override var isRefreshControlNeeded: Bool { false }
    override var isBottomViewNeeded: Bool { true }
    override var isCustomHeadlineView: Bool { true }
    override var bottomForceInset: CGFloat? {
        (bottomView?.bounds.height ?? 0) + (keyboardHeight == 0 ? UIScreen.main.homeIndicatorInset : keyboardHeight)
    }
    override var activityIndicatorSourceView: UIView? { view }

    private let keyboardObserver: KeyboardObserver = .init()

    private var keyboardHeight: CGFloat = 0 {
        didSet {
            bottomViewStack?.padding(.bottom(keyboardHeight == 0 ? UIScreen.main.homeIndicatorInset : keyboardHeight))
            adjustTableView()
            interactor?.changeHeight(.init())
        }
    }

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
        (view as? View)?.corner(radius: 12)
        interactor?.loadV2(.initial)

        keyboardObserver.observeKeyboard(notifications: [.willShow, .willHide]) { [weak self] payload, _ in
            self?.keyboardHeight = payload.trueKeyboardHeight
        }

        (headlineView as? BottomSheetHeadlineView).let {
            BottomSheetHeadlineView.Model(headline: Localization.SearchHiddenUser.title.localized.attrString).setup(view: $0)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutSubviewsRecursively()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardHeight = 0
    }

    override func makeHeadlineView() -> View {
        BottomSheetHeadlineView()
    }

    override func makeBottomView() -> View {
        let button = ButtonBarStack()
        ButtonBarStack.Model(buttons: [.init(text: Localization.SearchHiddenUser.find.localized, isEnabled: false) { [weak self] in
                    self?.view.endEditing(true)
                    self?.interactor?.onSearch(.init())
                }])
                .setup(view: button)
        return button
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        switch cell {
        case let cell as InputCell:
            cell.input.didChange = { [weak interactor, weak self] field in
                interactor?.onInputChanged(.init(text: field.text ?? ""))
                (self?.bottomView as? ButtonBarStack)?.topButton?.isEnabled(field.text?.isEmpty == false)
            }
        default: break
        }
    }

    override func displayError(_ viewModel: ErrorHandling.ViewModel) {
        if tableView.contentOffset.y < tableView.contentInset.top {
            scroll(to: .zero)
        }

        Self.showOnMainWindow(with: .init(text: viewModel.message.style(.line.multiline)))
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        SPStorkController.scrollViewDidScroll(scrollView)
    }
}
