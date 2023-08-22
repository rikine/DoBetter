//
//  PhoneCodeEnterViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 11.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes
import SPStorkController

protocol PhoneCodeEnterDisplayLogic: TableDisplayLogic {
    func displayTimer(_ viewModel: PhoneCodeEnter.Timer.ViewModel)
}

class PhoneCodeEnterViewController: TableViewNodeController,
                                    PhoneCodeEnterDisplayLogic,
                                    TableDisplaying {

    private typealias PhoneCode = Localization.PhoneCode

    weak var interactor: PhoneCodeEnterBusinessLogic?
    override var cellModelTypes: [CellViewAnyModel.Type] { [InputCell.Model.self] }
    override var isRefreshControlNeeded: Bool { false }
    override var isBottomViewNeeded: Bool { true }
    override var isCustomHeadlineView: Bool { true }
    override var bottomForceInset: CGFloat? {
        (bottomView?.bounds.height ?? 0) + (keyboardHeight == 0 ? UIScreen.main.homeIndicatorInset : keyboardHeight)
    }
    override var activityIndicatorSourceView: UIView? { view }

    private var retryText: Text!
    private var timer: Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }

    private var timerSetTime: Date?

    private var differenceTime: Int? { timerSetTime.map { Date().seconds(from: $0) } }

    private var isEnabled: Bool { shouldSkip ? true : (differenceTime ?? 0) >= 60 }
    private var shouldSkip: Bool = false

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
            BottomSheetHeadlineView.Model(headline: PhoneCode.title.localized.attrString).setup(view: $0)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateRetryLabel()
    }

    override func makeHeadlineView() -> View {
        BottomSheetHeadlineView()
    }

    override func makeBottomView() -> View {
        VStack().spacing(12).config(backgroundColor: .clear).content {
            retryText = Text().padding(.horizontal(16)).onTap { [weak self] in
                guard self?.isEnabled == true else { return }
                self?.view.endEditing(true)
                self?.interactor?.onButtonTap(.init(button: .retry))
            }

            let button = ButtonBarStack()
            let buttonType = PhoneCodeEnter.Button.send

            ButtonBarStack.Model(buttons: [.init(text: buttonType.title) { [weak self] in
                        self?.view.endEditing(true)
                        self?.interactor?.onButtonTap(.init(button: buttonType))
                    }])
                    .setup(view: button)
        }
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        switch cell {
        case let cell as InputCell:
            cell.input.didChange = { [weak interactor] field in
                interactor?.onCodeChanged(.init(code: field.text ?? ""))
            }
        default: break
        }
    }

    private func updateRetryLabel() {
        let code: AttrString
        let diff = differenceTime.map { max(0, 60 - $0) } ?? 0
        if diff > 0 {
            code = "\(PhoneCode.sendCodeAfter1.localized) \(String(diff), .empty.accent) \(PhoneCode.sendCodeAfter2.localized)"
        } else {
            code = "\(PhoneCode.questionCode1.localized) \(isEnabled ? PhoneCode.questionCode2.localized : "", .empty.accent)\(!isEnabled ? PhoneCode.questionCode3.localized : "")"
        }
        retryText.text(code.apply(.label.multiline.secondary.center))
        interactor?.changeHeight(.init())
    }

    func displayTimer(_ viewModel: PhoneCodeEnter.Timer.ViewModel) {
        shouldSkip = false
        switch viewModel.state {
        case .remove:
            timerSetTime = nil
            timer = nil
        case .set:
            timerSetTime = Date()
            timer = makeTimer()
        case .skip:
            shouldSkip = true
            updateRetryLabel()
        }
    }

    private func makeTimer() -> Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.updateRetryLabel()
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

    deinit {
        timer?.invalidate()
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }

    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
