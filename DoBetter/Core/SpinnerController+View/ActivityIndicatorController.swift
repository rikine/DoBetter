//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit
import SwiftGifOrigin

extension ActivityIndicatorController {

    static let animationDuration = 0.2

    static let animationDelay = animationDuration * 2

    static let spinnerImageHeight: CGFloat = UIImage.ActivityIndication.medium.height

    static let backgroundColor = UIColor.accent
}

protocol ActivityIndicatorControllerDelegate: AnyObject {
    func controllerWillShowSpinner(_ controller: ActivityIndicatorController)

    func controllerDidShowSpinner(_ controller: ActivityIndicatorController)

    func controllerWillHideSpinner(_ controller: ActivityIndicatorController)

    func controllerDidHideSpinner(_ controller: ActivityIndicatorController)

    func controllerShouldStartObservingSpinner(_ controller: ActivityIndicatorController) -> Bool

    func controllerShouldStopObservingSpinner(_ controller: ActivityIndicatorController) -> Bool
}

extension ActivityIndicatorControllerDelegate {
    func controllerWillShowSpinner(_ controller: ActivityIndicatorController) {}

    func controllerDidShowSpinner(_ controller: ActivityIndicatorController) {}

    func controllerWillHideSpinner(_ controller: ActivityIndicatorController) {}

    func controllerDidHideSpinner(_ controller: ActivityIndicatorController) {}

    func controllerShouldStartObservingSpinner(_ controller: ActivityIndicatorController) -> Bool { true }

    func controllerShouldStopObservingSpinner(_ controller: ActivityIndicatorController) -> Bool { true }
}

final class  ActivityIndicatorController {

    weak var delegate: ActivityIndicatorControllerDelegate?

    private var isSpinnerInstalled = false

    private weak var sourceView: UIView?

    private lazy var spinnerView: UIView? = sourceView
        .map { _ in SpinnerView.create(style: .lightBackground(.background2)) }

    var isVisible: Bool {
        get { isSpinnerInstalled }
        set { newValue ? installSpinner() : removeSpinner() }
    }

    init(sourceView: UIView) {
        self.sourceView = sourceView
    }

    private func installSpinner() {
        guard let sourceView, let spinnerView else { return }
        delegate?.controllerWillShowSpinner(self)
        isSpinnerInstalled = true
        sourceView.addSubview(spinnerView, constraints: .fill)
        spinnerView.alpha = 0

        UIView.animate(withDuration: ActivityIndicatorController.animationDuration,
                       delay: ActivityIndicatorController.animationDelay,
                       options: [.beginFromCurrentState, .curveEaseIn],
                       animations: { spinnerView.alpha = 1 },
                       completion: { [weak self] _ in
                           guard let self else { return }
                           self.delegate?.controllerDidShowSpinner(self)
                       })
    }

    private func removeSpinner() {
        delegate?.controllerWillHideSpinner(self)
        isSpinnerInstalled = false

        UIView.animate(withDuration: ActivityIndicatorController.animationDuration,
                       delay: ActivityIndicatorController.animationDelay,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: { self.spinnerView?.alpha = 0 }, completion: { [weak self] _ in
            guard let self else { return }

            if !self.isSpinnerInstalled {
                self.spinnerView?.removeFromSuperview()
                self.delegate?.controllerDidHideSpinner(self)
            }
        })
    }

    // MARK: - Overrides

    func startObserving() {
        if delegate?.controllerShouldStartObservingSpinner(self) == true {
            spinnerView?.removeFromSuperview()
        }
    }

    func stopObserving() {
        if delegate?.controllerShouldStopObservingSpinner(self) == true {
            removeSpinner()
        }
    }
}
