//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import UIKit
import Photos
import AVFoundation

protocol CommonDocumentsPickerCoordinator: AnyObject {
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate { get }
    var pickerController: UIImagePickerController? { get set }

    func showSourceSelector()
}

extension CommonDocumentsPickerCoordinator where Self: UIViewController {
    func showSourceSelector() {
        let picker = UIAlertController(title: "Pick source", message: nil, preferredStyle: .actionSheet)
        picker.addAction(.init(title: "Gallery", style: .default) { [weak self] _ in
            self?.checkGalleryAccess()
        })
        picker.addAction(.init(title: "Camera", style: .default) { [weak self] _ in
            self?.checkCameraAccess()
        })
        picker.addAction(.init(title: "Cancel", style: .destructive))
        present(picker, animated: true)
    }

    func checkGalleryAccess() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard status == .authorized else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.showGalleryPicker()
                }
            }
        case .denied, .restricted:
            present(standartAlertWithSettings(title: "Разрешите доступ к галерее",
                                              message: "Для этого перейдите в настройки.",
                                              abortTitle: "Не сейчас",
                                              settingsTitle: "В Настройки"), animated: true)
        case .authorized, .limited:
            showGalleryPicker()
        default: break
        }
    }

    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.showCameraPicker()
                }
            }
        case .denied, .restricted:
            present(standartAlertWithSettings(title: "Разрешите доступ к камере",
                                              message: "Для этого перейдите в настройки.",
                                              abortTitle: "Не сейчас",
                                              settingsTitle: "В Настройки"), animated: true)
        case .authorized:
            showCameraPicker()
        default: break
        }
    }

    func showGalleryPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else { return }
        let pickerController = makePickerController(with: .photos)
        self.pickerController = pickerController
        present(pickerController, animated: true)
    }

    func showCameraPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let pickerController = makePickerController(with: .camera)
        self.pickerController = pickerController
        present(pickerController, animated: true)
    }
}

extension CommonDocumentsPickerCoordinator {
    private func makePickerController(with type: CameraType) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = delegate

        switch type {
        case .camera:
            controller.sourceType = .camera
            controller.allowsEditing = false
            controller.showsCameraControls = true
        case .photos:
            controller.sourceType = .photoLibrary
        }

        return controller
    }
}

enum CameraType {
    case camera, photos
}

extension UIViewController {
    func standardAlert(title: String,
                       message: String? = nil,
                       cancelTitle: String,
                       actionTitle: String,
                       onCancel: VoidClosure? = nil,
                       onAction: VoidClosure? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: cancelTitle, style: .destructive) { _ in onCancel?() }

        let action = UIAlertAction(title: actionTitle, style: .default) { _ in onAction?() }

        alert.addAction(cancelAction)
        alert.addAction(action)

        return alert
    }

    func standartAlertWithSettings(title: String,
                                   message: String,
                                   abortTitle: String,
                                   settingsTitle: String,
                                   onCancel: (() -> Void)? = nil,
                                   onSettingsOpen: (() -> Void)? = nil) -> UIAlertController {
        standardAlert(title: title, message: message, cancelTitle: abortTitle, actionTitle: settingsTitle, onCancel: onCancel) {
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url)
            else { return }
            onSettingsOpen?()
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
