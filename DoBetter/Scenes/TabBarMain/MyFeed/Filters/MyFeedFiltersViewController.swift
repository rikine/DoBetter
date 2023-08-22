//
//  MyFeedFiltersViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 09.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ViewNodes
import SPStorkController

protocol MyFeedFiltersDisplayLogic: TableDisplayLogic {
    func displayOnSectionPick(_ viewModel: CreateTask.SectionPicker.ViewModel)
}

/// TODO: localization, fix icons and texts, tasks to profile, count of likes
class MyFeedFiltersViewController: TableViewNodeController,
                                   MyFeedFiltersDisplayLogic,
                                   TableDisplaying {

    weak var interactor: MyFeedFiltersBusinessLogic?
    override var isRefreshControlNeeded: Bool { false }
    override var isBottomViewNeeded: Bool { true }
    override var isCustomHeadlineView: Bool { true }
    override var bottomForceInset: CGFloat? {
        (bottomView?.bounds.height ?? 0) + (keyboardHeight == 0 ? UIScreen.main.homeIndicatorInset : keyboardHeight)
    }

    override var activityIndicatorSourceView: UIView? { view }

    override var cellModelTypes: [CellViewAnyModel.Type] {
        [TextCell.Cell.Model.self,
         BottomSheetHeadlineView.Cell.Model.self,
         TaskSectionPickerView.CollectionFlow.self,
         CheckboxView.Cell.Model.self]
    }

    private var buttonBar: ButtonBarStack!
    private var wrappedPickerView: UIViewWrapper<UIDatePicker>!
    private var pickerStackView: VStack!
    private var clearPickerButton: Text!
    private var donePickerButton: Text!

    private var currentDateType: MyFeedFilters.DateFilter?

    private func makePickerView() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        return picker
    }

    let keyboardObserver: KeyboardObserver = .init()

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
        (view as? View)?.corner(radius: 12)
        super.viewDidLoad()
        interactor?.loadV2(.initial)
        hideKeyboardWhenTappedAround()

        displayButtonBar()

        keyboardObserver.observeKeyboard(notifications: [.willShow, .willHide]) { [weak self] payload, _ in
            self?.keyboardHeight = payload.trueKeyboardHeight
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor?.changeHeight(.init())
    }

    func displayButtonBar() {
        ButtonBarStack.Model(buttons: [.init(text: Localization.save.localized) { [weak interactor] in
                    interactor?.onSave(.init())
                }])
                .setup(view: buttonBar)
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as TextCell.Cell, let model as TextCell.Cell.Model):
            if let date = model.payload as? MyFeedFilters.DateFilter {
                let selectedDate: Date?
                switch date {
                case .to(let currentDate): selectedDate = currentDate
                case .from(let currentDate): selectedDate = currentDate
                case .toEnd(let currentDate): selectedDate = currentDate
                case .fromEnd(let currentDate): selectedDate = currentDate
                }

                cell.mainView.onTap { [weak self] in
                    self?.currentDateType = date
                    self?.showHidePicker(shouldHide: false, selectedDate: nil, shouldUpdateDate: false)
                    self?.wrappedPickerView.wrapped.setDate(selectedDate ?? Date(), animated: true)
                }
            }
        case (let cell as FlowCollectionCell, _):
            cell.paddingTop = 16
            cell.paddingBottom = 0
        case (let cell as CheckboxView.Cell, let model as CheckboxView.Cell.Model):
            cell.mainView.rightButton.onTap { [weak interactor] in
                guard let payload = model.payload as? MyFeedFilters.DoneFilter else { return }
                interactor?.doneFilter(.init(filter: payload))
            }
        case (let cell as BottomSheetHeadlineView.Cell, _):
            cell.mainView.rightText.onTap { [weak interactor] in
                interactor?.clear(.init())
            }
        default: break
        }
    }

    func displayOnSectionPick(_ viewModel: CreateTask.SectionPicker.ViewModel) {
        interactor?.onSectionPick(.init(section: viewModel.section))
    }

    private func showHidePicker(shouldHide: Bool, selectedDate: Date?, shouldUpdateDate: Bool = true) {
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerStackView.alpha = shouldHide ? 0 : 1
        }) { [weak self] _ in
            self?.pickerStackView.hidden(shouldHide)
            self?.view.layoutSubviewsRecursively()
            self?.adjustTableView()
            self?.interactor?.changeHeight(.init())
        }

        if shouldHide && shouldUpdateDate, let currentDateType {
            interactor?.onDatePick(.init(selectedDate: selectedDate, type: currentDateType))
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        SPStorkController.scrollViewDidScroll(scrollView)

        if !pickerStackView.isHidden {
            showHidePicker(shouldHide: true, selectedDate: nil, shouldUpdateDate: false)
        }
    }

    override func makeBottomView() -> View {
        ZStack().content {
            buttonBar = ButtonBarStack().position(.bottom)
            pickerStackView = VStack().hidden(true).content {
                HStack().config(backgroundColor: .content2).padding(.horizontal(16) + .vertical(8)).content {
                    clearPickerButton = Text(Localization.clear.localized.style(.line.color(.accent))).onTap { [weak self] in
                        self?.showHidePicker(shouldHide: true, selectedDate: nil)
                    }

                    View().width(.fill)

                    donePickerButton = Text(Localization.done.localized.style(.line.color(.accent))).onTap { [weak self] in
                        self?.showHidePicker(shouldHide: true, selectedDate: self?.wrappedPickerView.wrapped.date)
                    }
                }
                wrappedPickerView = .init(makePickerView())
            }
        }
    }
}
