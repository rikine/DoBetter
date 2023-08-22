//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

struct UserError: LocalizedError {
    let errorDescription: String?
    let failureReason: String? = nil
    let recoverySuggestion: String? = nil
    let helpAnchor: String? = nil

    init(_ description: String) {
        errorDescription = description
    }
}

enum ErrorHandling {

    enum ViewType {
        case alert, banner, placeholder

        static func tableType(_ isEmpty: Bool) -> ViewType {
            // Show alert if contents was on screen, placeholder otherwise
            isEmpty ? .placeholder : .alert
        }
    }

    struct ViewModel {

        let title: String?
        let message: String?
        let errorMessage: String?
        let type: ViewType

        init(title: String? = nil, message: String?, errorMessage: String? = nil, type: ViewType = .alert) {
            self.title = title
            self.message = message
            self.errorMessage = errorMessage
            self.type = type
        }

        init(fromError error: Error, title: String? = nil, type: ViewType = .alert) {
            self.init(title: title,
                      message: error.localizedDescription,
                      errorMessage: "\(error)",
                      type: type)
        }
    }

    struct Response {
        let error: Error
        let type: ViewType

        init(error: Error, type: ViewType = .alert) {
            self.error = error
            self.type = type
        }
    }
}

extension Error {

    func isEqual<E: Error & Equatable>(_ other: E) -> Bool {
        if let error = self as? E {
            return error == other
        } else {
            return false
        }
    }
}

// MARK: - Display Logic

protocol ErrorDisplaying: AnyObject {
    func displayError(_ viewModel: ErrorHandling.ViewModel)
}

extension ErrorDisplaying where Self: UIViewController {

    /// Call in common cases, also you can implement custom logic of this method
    /// in your ViewController and then call `displayDefaultError` if needed.
    func displayError(_ viewModel: ErrorHandling.ViewModel) {
        displayDefaultError(viewModel)
    }

    /// Call only from inside ViewController if you implemented custom `displayError` logic,
    /// but you still need logic from `ErrorDisplaying`
    func displayDefaultError(_ viewModel: ErrorHandling.ViewModel) {
        switch viewModel.type {
        case .alert:
            displayDefaultErrorAlert(viewModel)
        case .banner:
            displayDefaultErrorBanner(viewModel)
        case .placeholder:
            /// See `extension DefaultErrorPresenting where ViewController: TableViewController`
            break
        }
    }

    private func displayDefaultErrorAlert(_ viewModel: ErrorHandling.ViewModel) {
        guard !(presentedViewController is UIAlertController) else { return }

        let alert = UIAlertController.nonFatalError(title: viewModel.title,
                                                    message: viewModel.message,
                                                    errorMessage: viewModel.errorMessage)

        UIApplication.topViewController.present(alert, animated: true)
    }

    private func displayDefaultErrorBanner(_ viewModel: ErrorHandling.ViewModel) {
        guard let message = viewModel.message else { return }
        showNotify(with: .init(text: message.style(.line.multiline)))
    }
}

extension UIAlertController {
    private static let _title =
        NSLocalizedString("Ошибка",
                          comment: "Заголовок алерта при возврате ошибки сервером")

    private static let _discardText =
        NSLocalizedString("OK",
                          comment: "Кнопка отмены для алерта при возврате ошибки сервером")

    private static let _copyErrorText =
        NSLocalizedString("Copy", comment: "Кнопка для копирования текста ошибки")

    static func nonFatalError(title: String? = nil,
                              message: String?,
                              errorMessage: String? = nil,
                              discardHandler: (() -> Void)? = nil) -> UIAlertController {
        let newTitle = title ?? UIAlertController._title
        let alert = UIAlertController(title: newTitle,
                                      message: message,
                                      preferredStyle: .alert)

        let discardAction = UIAlertAction(title: UIAlertController._discardText,
                                          style: .default) { [unowned alert] _ in
            discardHandler?()
            alert.dismiss(animated: true)
        }

        alert.addAction(discardAction)

        #if !DEBUG
            if let errorMessage {
                let copyErrorMessageAction = UIAlertAction(title: UIAlertController._copyErrorText,
                                                           style: .default) { _ in
                    UIPasteboard.general.string = errorMessage
                    discardHandler?()
                    alert.dismiss(animated: true)
                }
                alert.addAction(copyErrorMessageAction)
                alert.preferredAction = copyErrorMessageAction
            }
        #endif

        return alert
    }
}

/// TODO: Move!
extension UIApplication {
    static var topViewController: UIViewController {
        shared.keyWindow?.rootViewController?.mostTopViewController
            ?? UIViewController(nibName: nil, bundle: nil)
    }

    static var topFullscreenViewController: UIViewController {
        shared.keyWindow?.rootViewController?.mostTopFullscreenViewController
            ?? UIViewController(nibName: nil, bundle: nil)
    }
}

extension UIViewController {
    var mostTopViewController: UIViewController {
        mostTopViewController(0).viewController
    }

    var mostTopFullscreenViewController: UIViewController {
        mostTopViewController(0) { $0.view.frame == UIScreen.main.bounds }.viewController
    }

    func hideBackTitle() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
}

extension UIViewController {
    private struct MostTopViewController: Comparable {
        let viewController: UIViewController
        let depth: Int

        static func <(lhs: MostTopViewController, rhs: MostTopViewController) -> Bool {
            lhs.depth < rhs.depth
        }

        static func <=(lhs: MostTopViewController, rhs: MostTopViewController) -> Bool {
            lhs.depth <= rhs.depth
        }

        static func >=(lhs: MostTopViewController, rhs: MostTopViewController) -> Bool {
            lhs.depth >= rhs.depth
        }

        static func >(lhs: MostTopViewController, rhs: MostTopViewController) -> Bool {
            lhs.depth > rhs.depth
        }
    }

    private func mostTopViewController(
        _ depth: Int,
        _ predicate: (UIViewController) -> Bool = { _ in true }
    ) -> MostTopViewController {
        if let presented = presentedViewController, predicate(presented) {
            return presented.mostTopViewController(depth + 1, predicate)
        }
        if let result = (children.filter(predicate).map {
            $0.mostTopViewController(depth + 1, predicate)
        })
                .max() {
            return result
        }
        return MostTopViewController(viewController: self, depth: depth)
    }
}

extension UIViewController {
    func dismissMany(completion: (() -> Void)? = nil) {
        var presenting = self
        while let presented = presenting.presentedViewController {
            presented.modalTransitionStyle = .crossDissolve
            if presented.presentedViewController == nil {
                presented.blind { [weak self] _ in
                    self?.dismiss(animated: true, completion: completion)
                }
            } else {
                presented.blind()
            }
            presenting = presented
        }
    }

    func blind(completion: ((Bool) -> Void)? = nil) {
        let blink = UIView(frame: view.bounds)
        blink.backgroundColor = .background2
        if let completion = completion {
            blink.alpha = 0
            UIView.animate(withDuration: Animation.Duration.default, animations: {
                blink.alpha = 1
            }, completion: completion)
        }
        view.addSubview(blink)
    }
}

/* ================================================================================================================== */

// MARK: - Presentation Logic

/// Your `...PresentationLogic` protocol can inherit this protocol.
protocol ErrorPresenting: AnyObject {
    var loadFailurePlaceholder: TableStopperViewModel { get }
    func presentError(_ response: ErrorHandling.Response)
}

extension ErrorPresenting {
    /// Implement in presenter if you need custom table placeholder for request error
    var loadFailurePlaceholder: TableStopperViewModel { .sorryPlaceholder }
}

/// Conform your presenter to this protocol if you want the default error handling behaviour
/// (taking the `localizedDescription` of an error and sending it to the view controller
///
/// - Important: DO NOT inherit your `...PresentationLogic` protocol from this protocol!
///              Otherwise we're leaking the presenter's implementation details to the interactor,
///              allowing the interactor to talk to the view controller. **We don't want that**.
///              Inherit your `...PresentationLogic` protocol from the `ErrorPresenting` protocol instead.
protocol DefaultErrorPresenting: ErrorPresenting {
    associatedtype ViewController
    var viewController: ViewController? { get }

    func presentErrorPlaceholder(_ response: ErrorHandling.Response)
}

extension DefaultErrorPresenting {

    func presentDefaultError(_ response: ErrorHandling.Response) {
        response.type == .placeholder
            ? presentErrorPlaceholder(response)
            : errorDisplaying?.displayError(.init(fromError: response.error, type: response.type))
    }

    func presentErrorPlaceholder(_ response: ErrorHandling.Response) {
        if let tableDisplaying = viewController as? TableDisplayLogic {
            tableDisplaying.displayPlaceholder(loadFailurePlaceholder)
        }
    }

    func presentError(_ response: ErrorHandling.Response) {
        presentDefaultError(response)
    }

    var errorDisplaying: ErrorDisplaying? {
        // We perform a runtime check and not a compile-time check
        // because adding a constraint to the associated type means that
        // it can only be satisfied by a concrete type, not a protocol, which is our case.
        assertionCast(viewController, to: ErrorDisplaying.self)
    }
}

extension ErrorPresenting where Self: ErrorDisplaying {
    func presentError(_ response: ErrorHandling.Response) {
        displayError(.init(fromError: response.error, type: response.type))
    }
}
