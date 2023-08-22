//
//  ProfileEditViewController.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import ImageViewer_swift

protocol ProfileEditDisplayLogic: TableDisplayLogic {
}

class ProfileEditViewController: TableViewNodeController,
                                 ProfileEditDisplayLogic,
                                 TableDisplaying,
                                 CommonDocumentsPickerCoordinator,
                                 KeyboardObservableTable,
                                 SnackNotificationDisplayer {
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate { self }
    var pickerController: UIImagePickerController?

    weak var interactor: ProfileEditBusinessLogic?
    override var isRefreshControlNeeded: Bool { false }
    override var cellModelTypes: [CellViewAnyModel.Type] {
        [UploadImageView.Cell.Model.self, InputCell.Model.self, TextAreaView.Cell.Model.self]
    }

    private var imagePickerController: UIImagePickerController?

    var keyboardObserver: KeyboardObserver = .init()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Localization.Profile.Edit.title.localized
        navigationItem.rightBarButtonItem = .makeCustomItem(iconModel: .Task.tick.glyphSize(.square(16))) { [weak interactor] in
            self.view.endEditing(true)
            interactor?.save(.init())
        }

        hideKeyboardWhenTappedAround()
        observeKeyboardAndOffsetRootView()

        interactor?.loadV2(.initial)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
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

                self?.interactor?.onTextEdited(.init(text: view.textView.text, id: inputID))
            }
        case (let cell as InputCell, let model as InputCell.Model):
            cell.input.endEditing = { [weak self] field in
                guard let inputID = model.payload as? CommonInputID else { return }

                var model = model
                model.inputModel.value = field.attributedText
                self?.sections[indexPath] = model

                self?.interactor?.onTextEdited(.init(text: field.text ?? "", id: inputID))
            }
        default: break
        }
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        interactor?.onImageEdited(.init(image: image))
        picker.dismiss(animated: true)
    }
}
