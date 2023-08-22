//
//  CreateTaskViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 03.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import SPStorkController
import ViewNodes
import ImageViewer_swift

protocol CreateTaskDisplayLogic: TableDisplayLogic {
    func onColorPick(_ viewModel: CreateTask.ColorPicker.ViewModel)
    func displayOnSectionPick(_ viewModel: CreateTask.SectionPicker.ViewModel)
}

class CreateTaskViewController: TableViewNodeController,
                                CreateTaskDisplayLogic,
                                TableDisplaying,
                                KeyboardObservableTable,
                                CommonDocumentsPickerCoordinator,
                                SnackNotificationDisplayer {
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate { self }

    var pickerController: UIImagePickerController?

    weak var interactor: CreateTaskBusinessLogic?

    override var cellModelTypes: [CellViewAnyModel.Type] {
        [InputCell.Model.self, UploadImageView.Cell.Model.self,
         TextAreaView.Cell.Model.self, TextCell.Cell.Model.self,
         BottomSheetHeadlineView.Cell.Model.self,
         ColorPickerView.CollectionFlow.self, TaskSectionPickerView.CollectionFlow.self]
    }
    override var isRefreshControlNeeded: Bool { false }
    override var isBottomViewNeeded: Bool { true }
    override var isCustomHeadlineView: Bool { true }
    override var bottomForceInset: CGFloat? {
        (bottomView?.bounds.height ?? 0) + (keyboardHeight == 0 ? UIScreen.main.homeIndicatorInset : keyboardHeight)
    }

    override var activityIndicatorSourceView: UIView? { view }

    private var buttonBar: ButtonBarStack!
    private var wrappedPickerView: UIViewWrapper<UIDatePicker>!
    private var pickerStackView: VStack!
    private var clearPickerButton: Text!
    private var donePickerButton: Text!

    private func makePickerView() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        return picker
    }

    let keyboardObserver: KeyboardObserver = .init()

    private var keyboardHeight: CGFloat = 0 {
        didSet {
            bottomViewStack?.padding(.bottom(keyboardHeight == 0 ? UIScreen.main.homeIndicatorInset : keyboardHeight))
            adjustTableView()
            interactor?.updateHeight(.init())
        }
    }

    // MARK: View lifecycle

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 120
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }

    override func loadView() {
        super.loadView()
        (view as? View)?.corner(radius: 12)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor?.loadV2(.initial)
        hideKeyboardWhenTappedAround()

        displayButtonBar()

        keyboardObserver.observeKeyboard(notifications: [.willShow, .willHide]) { [weak self] payload, _ in
            self?.keyboardHeight = payload.trueKeyboardHeight
        }
    }

    override func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.modify(cell: cell, forRowAt: indexPath)

        let model = sections[indexPath]

        switch (cell, model) {
        case (let cell as UploadImageView.Cell, _):
            cell.mainView.info.onTap { [weak self] in
                self?.view.endEditing(true)
                self?.showSourceSelector()
            }
            cell.mainView.remove.onTap { [weak self] in
                self?.view.endEditing(true)
                self?.interactor?.onImageEdited(.init(image: nil))
            }
//            cell.mainView.image.wrapped.setupImageViewer()
        case (let cell as TextAreaView.Cell, let model as TextAreaView.Cell.Model):
            cell.mainView.endEditing = { [weak self] view in
                guard let inputID = model.payload as? CommonInputID else { return }

                var model = model
                model.mainViewModel = model.mainViewModel.updatedModel(with: view)
                self?.sections[indexPath] = model

                self?.interactor?.onInputEdited(.init(text: view.textView.text, id: inputID))
            }
        case (let cell as InputCell, let model as InputCell.Model):
            cell.input.endEditing = { [weak self] field in
                guard let inputID = model.payload as? CommonInputID else { return }

                var model = model
                model.inputModel.value = field.attributedText
                self?.sections[indexPath] = model

                self?.interactor?.onInputEdited(.init(text: field.text ?? "", id: inputID))
            }
        case (let cell as TextCell.Cell, let model as TextCell.Cell.Model):
            if let date = model.payload as? CreateTask.DatePicker {
                let selectedDate: Date?
                switch date {
                case .model(let currentDate): selectedDate = currentDate
                }

                cell.mainView.onTap { [weak self] in
                    self?.showHidePicker(shouldHide: false, selectedDate: nil, shouldUpdateDate: false)
                    self?.wrappedPickerView.wrapped.setDate(selectedDate ?? Date(), animated: true)
                    self?.view.layoutSubviewsRecursively()
                }
            }
        case (let cell as FlowCollectionCell, _):
            cell.paddingTop = 16
            cell.paddingBottom = -8
        default: break
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

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        SPStorkController.scrollViewDidScroll(scrollView)

        if !pickerStackView.isHidden {
            showHidePicker(shouldHide: true, selectedDate: nil, shouldUpdateDate: false)
        }
    }

    func displayButtonBar() {
        ButtonBarStack.Model(buttons: [.init(text: Localization.save.localized) { [weak interactor] in
            interactor?.onSave(.init())
        }]).setup(view: buttonBar)
    }

    func onColorPick(_ viewModel: CreateTask.ColorPicker.ViewModel) {
        interactor?.onColorPick(.init(color: viewModel.color))
    }

    func displayOnSectionPick(_ viewModel: CreateTask.SectionPicker.ViewModel) {
        interactor?.onSectionPick(.init(section: viewModel.section))
    }

    private func showHidePicker(shouldHide: Bool, selectedDate: Date?, shouldUpdateDate: Bool = true) {
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerStackView.alpha = shouldHide ? 0 : 1
            self.updateTraitCollection()
        }) { [weak self] _ in
            self?.pickerStackView.hidden(shouldHide)
            self?.view.layoutSubviewsRecursively()
            self?.updateTraitCollection()
        }

        if shouldHide && shouldUpdateDate {
            interactor?.onDatePick(.init(selectedDate: selectedDate))
        }
    }

    private func updateTraitCollection() {
        UITraitCollection.current = UITraitCollection(userInterfaceStyle: UIScreen.main.traitCollection.userInterfaceStyle)
    }
}

extension CreateTaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        interactor?.onImageEdited(.init(image: image))
        picker.dismiss(animated: true)
    }
}
