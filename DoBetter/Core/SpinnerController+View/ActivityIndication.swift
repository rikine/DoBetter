//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

enum ActivityIndication {
    enum Style {
        case darkBackground(color: SpinnerColor = .default)
        case lightBackground(_ backgroundColor: UIColor)

        enum SpinnerColor {
            case `default`
            case small

            var image: UIImage {
                switch self {
                case .default: return .ActivityIndication.whiteSpiner
                case .small: return .ActivityIndication.whiteSpinerSmall
                }
            }
        }
    }

    enum FadeInOutAnimation {
        case none
        case immediately
        case delayed

        init(animatedImmediately: Bool) {
            self = animatedImmediately ? .immediately : .delayed
        }
    }

    struct Response {

        /// Is activity indicator shown? Setting this to `true` presents the indicator if it hasn't been present.
        /// Setting to `false` removes the indicator if it has been visible.
        let isShown: Bool

        /// Set this to `false` if you want the activity indicator to appear with a short delay.
        /// This is appropriate if your activity (e. g. a network request) may end almost immediately and you
        /// don't want the indicator to blink.
        ///
        /// If you're displaying the indicator for the first time on a screen, it is better to set this to `true`.
        ///
        /// If you are dismissing the indicator that has been previously presented, i. e. `isShown == false`,
        /// you want to set this to `true`.
        let immediately: Bool

        let ignoreRefreshControl: Bool

        let message: NSAttributedString?

        /// Create a new activity indicator configureation for presenters.
        ///
        /// - Parameters:
        ///   - isShown: Is activity indicator shown? Setting this to `true` presents the indicator if it hasn't been
        ///              present. Setting to `false` removes the indicator if it has been visible.
        ///   - immediately: Set this to `false` if you want the activity indicator to appear with a short delay.
        ///                  This is appropriate if your activity (e. g. a network request) may end almost immediately
        ///                  and you don't want the indicator to blink. If you're displaying the indicator for the first
        ///                  time on a screen, it is better to set this to `true`. If you are dismissing the indicator
        ///                  that has been previously presented, i. e. `isShown == false`,
        ///                  you want to set this to `true`.
        init(isShown: Bool,
             immediately: Bool,
             ignoreRefreshControl: Bool = false,
             message: NSAttributedString? = nil) {
            self.isShown = isShown
            self.immediately = immediately
            self.ignoreRefreshControl = ignoreRefreshControl
            self.message = message
        }
    }

    struct ViewModel {

        let isShown: Bool
        let immediately: Bool
        let message: NSAttributedString?
        let ignoreRefreshControl: Bool
        var spinnerSize: CGSize?

        /// For now animation in activity indicator displaying/removal doesn't match animationStyle.
        /// Set them in `installActivityIndicator` and `removeActivityIndicator` gives you
        /// nothing because it breaks activity indicator in a lot of places.
        /// You can have problems when you call some methods (probably related to layout)
        /// and also have `immediately: true` but your methods work incorrectly.
        ///
        /// Use if you call func after activity indicator was completely appeared.
        var onInstall: (() -> Void)?

        /// Use if you call func after activity indicator was completely removed.
        var onRemove: (() -> Void)?

        init(isShown: Bool,
             immediately: Bool,
             message: NSAttributedString? = nil,
             ignoreRefreshControl: Bool = false,
             spinnerSize: CGSize? = nil,
             onInstall: (() -> Void)? = nil,
             onRemove: (() -> Void)? = nil) {
            self.isShown = isShown
            self.immediately = immediately
            self.message = message
            self.ignoreRefreshControl = ignoreRefreshControl
            self.spinnerSize = spinnerSize
            self.onInstall = onInstall
            self.onRemove = onRemove
        }
    }
}

// MARK: - Display Logic

protocol ActivityIndicationDisplaying: AnyObject {

    /// If you don't want to fully implement the `displayActivityIndication(_:)` method yourself, you can take
    /// advantage of the default implementation and only provide a view in which you want to display an activity
    /// indicator by returning that view via this property.
    var activityIndicatorSourceView: UIView? { get }
    var activityIndicationBackgroundColor: UIColor { get }

    func displayActivityIndication(_ viewModel: ActivityIndication.ViewModel)
    func displayDefaultActivityIndication(_ viewModel: ActivityIndication.ViewModel)
}

extension ActivityIndicationDisplaying where Self: UIViewController {

    var activityIndicatorSourceView: UIView? { navigationController?.view ?? view }

    var activityIndicationBackgroundColor: UIColor {
        ActivityIndicatorController.backgroundColor
    }

    func displayActivityIndication(_ viewModel: ActivityIndication.ViewModel) {
        displayDefaultActivityIndication(viewModel)
    }

    func displayDefaultActivityIndication(_ viewModel: ActivityIndication.ViewModel) {
        guard let activityIndicatorSourceView else { return }

        let animation = ActivityIndication.FadeInOutAnimation(animatedImmediately: viewModel.immediately)

        // Only one activity indicator per source view.
        if viewModel.isShown {
            if let indicator = (activityIndicatorSourceView.subviews.compactMap { $0 as? SpinnerView }).first {

                indicator.setMessage(viewModel.message, animated: !viewModel.immediately)
                installActivityIndicator(indicator, into: activityIndicatorSourceView, animationStyle: animation)
            } else {
                let indicator = SpinnerView.create(style: .lightBackground(activityIndicationBackgroundColor),
                                                                spinnerSize: viewModel.spinnerSize)
                indicator.setMessage(viewModel.message, animated: false)
                installActivityIndicator(indicator, into: activityIndicatorSourceView, animationStyle: animation, completion: viewModel.onInstall)
            }
        } else if !viewModel.isShown {
            activityIndicatorSourceView.subviews
                .compactMap { $0 as? SpinnerView }
                .forEach { removeActivityIndicator($0, animationStyle: animation, completion: viewModel.onRemove) }
        }
    }
}

extension ActivityIndicationDisplaying {

    func installActivityIndicator(_ indicator: SpinnerView,
                                  into sourceView: UIView,
                                  animationStyle: ActivityIndication.FadeInOutAnimation,
                                  alongsideAnimation: (() -> Void)? = nil,
                                  completion: (() -> Void)? = nil) {

        sourceView.addSubview(indicator, constraints: .fill)

        let sourceViewFadeOut: (() -> Void)?
        switch indicator.style {
        case .lightBackground:
            sourceViewFadeOut = nil
        case .darkBackground:
            sourceViewFadeOut = { sourceView.subviews.filter { $0 !== indicator }.forEach { $0.alpha = 0 } }
        }

        guard animationStyle != .none else {
            sourceViewFadeOut?()
            alongsideAnimation?()
            completion?()
            return
        }

        if animationStyle == .delayed {
            indicator.alpha = 0
            UIView.animate(withDuration: ActivityIndicatorController.animationDuration,
                           delay: ActivityIndicatorController.animationDelay,
                           options: [.beginFromCurrentState, .curveEaseIn],
                           animations: {
                               sourceViewFadeOut?()
                               alongsideAnimation?()
                               indicator.alpha = 1

                           },
                           completion: { _ in completion?() })
        } else {
            sourceViewFadeOut?()
            alongsideAnimation?()
            completion?()
        }

        UIView.animate(withDuration: ActivityIndicatorController.animationDuration,
                       delay: animationStyle == .delayed ? ActivityIndicatorController.animationDelay : 0,
                       options: [.beginFromCurrentState, .curveEaseIn],
                       animations: {
                           sourceViewFadeOut?()
                           alongsideAnimation?()
                           indicator.alpha = 1
                       },
                       completion: { _ in completion?() })
    }

    func removeActivityIndicator(_ indicator: SpinnerView,
                                 animationStyle: ActivityIndication.FadeInOutAnimation,
                                 alongsideAnimation: (() -> Void)? = nil,
                                 completion: (() -> Void)? = nil) {

        let sourceViewFadeIn: (() -> Void)?
        switch indicator.style {
        case .lightBackground:
            sourceViewFadeIn = nil
        case .darkBackground:
            sourceViewFadeIn = { indicator.superview?.subviews.filter { $0 !== indicator }.forEach { $0.alpha = 1 } }
        }

        guard animationStyle != .none else {
            indicator.removeFromSuperview()
            sourceViewFadeIn?()
            alongsideAnimation?()
            completion?()
            return
        }

        UIView.animate(withDuration: ActivityIndicatorController.animationDuration,
                       delay: animationStyle == .delayed ? ActivityIndicatorController.animationDelay : 0,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: {
                           sourceViewFadeIn?()
                           alongsideAnimation?()
                           indicator.alpha = 0
                       },
                       completion: { [weak indicator] finished in
                           if finished { indicator?.removeFromSuperview() }
                           completion?()
                       })
    }
}

// MARK: - Presentation Logic

protocol ActivityIndicationPresentationLogic: AnyObject {
    func presentActivityIndication(_ response: ActivityIndication.Response)
}

protocol ActivityIndicationPresenting: ActivityIndicationPresentationLogic {
    associatedtype ViewController

    var viewController: ViewController? { get }
}

extension ActivityIndicationPresenting {

    var aiDisplaying: ActivityIndicationDisplaying? {
        assertionCast(viewController, to: ActivityIndicationDisplaying.self)
    }

    func presentActivityIndication(_ response: ActivityIndication.Response) {
        aiDisplaying?.displayActivityIndication(.init(isShown: response.isShown,
                                                      immediately: response.immediately,
                                                      message: response.message,
                                                      ignoreRefreshControl: response.ignoreRefreshControl))
    }
}
