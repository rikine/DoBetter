//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

protocol NavigationBarHiding {
    var prefersNavigationBarHidden: Bool { get }
}

class BaseViewController: UIViewController {

    var safeAreaConstraints: [Constraint] {
        [.equal(\.leftAnchor),
         .equal(\.topAnchor, safeAreaTopAnchor),
         .equal(\.rightAnchor),
         .equal(\.bottomAnchor, safeAreaBottomAnchor)]
    }

    // MARK: - Spinner

    var isSpinnerNeeded: Bool { true }

    var spinnerController: ActivityIndicatorController?

    /// A property to override. Return `nil` if you don't want to show a spinner.
    ///
    /// By default returns a IBOutlet `spinnerView`. If the `spinnerView` is `nil`, returns the main `view`.
    var spinnerSourceView: UIView? { view }

    final var isSpinnerShown: Bool { spinnerController?.isVisible ?? false }

    var hasSeparator: Bool { false }
    var separator: UIView?

    private var _isStatusBarHidden = false

    var viewIsAppeared = false
    var viewWasNeverAppeared = true

    // MARK: - SnackBars
    var notificationSnackBar: SnackBar?
    var topSnackBar: SnackBar!
    var bottomSnackBar: SnackBar!

    var bottomSnackBarBottom: NSLayoutConstraint?
    var notificationModel: CommonSnack.Model?

    private func initSnackBar() {
        topSnackBar = makeSnackBar(.top)
        view.add(snackBar: topSnackBar, safeAreaTopAnchor: safeAreaTopAnchor)

        bottomSnackBar = makeSnackBar(.bottom)
        view.addSubview(bottomSnackBar, constraints: [
            .equal(\.leadingAnchor),
            .equal(\.trailingAnchor)
        ])
        bottomSnackBarBottom = bottomSnackBar.bottomAnchor.constraint(equalTo: safeAreaBottomAnchor, constant: 0)
        bottomSnackBarBottom?.isActive = true
    }

    public func makeSnackBar(_ position: SnackBar.Position) -> SnackBar {
        SnackBar(position: position)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.lifecycle.debug("viewDidLoad for \(type(of: self))")

        if isSpinnerNeeded {
            spinnerSourceView.map {
                spinnerController = ActivityIndicatorController(sourceView: $0)
            }
        }

        spinnerController?.delegate = self
        spinnerController?.startObserving()

        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setSeparator()
        initSnackBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewIsAppeared = true
        viewDidAppear(animated: animated, firstTime: viewWasNeverAppeared)
        if viewWasNeverAppeared {
            viewWasNeverAppeared = false
        }
        spinnerController?.startObserving()
    }

    func viewDidAppear(animated: Bool, firstTime: Bool) {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let hiding = self as? NavigationBarHiding, navigationController == parent {
            navigationController?.setNavigationBarHidden(hiding.prefersNavigationBarHidden, animated: animated)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewIsAppeared = false
        spinnerController?.stopObserving()
    }

    override var prefersStatusBarHidden: Bool { _isStatusBarHidden }

    func hideStatusBar(_ hide: Bool) {
        _isStatusBarHidden = hide
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - ActivityIndicatorControllerDelegate

    // declarations from extensions cannot be overridden yet
    func controllerWillShowSpinner(_ controller: ActivityIndicatorController) {}

    func controllerDidShowSpinner(_ controller: ActivityIndicatorController) {}

    func controllerWillHideSpinner(_ controller: ActivityIndicatorController) {}

    func controllerDidHideSpinner(_ controller: ActivityIndicatorController) {}

    func controllerShouldStartObservingSpinner(_ controller: ActivityIndicatorController) -> Bool { true }

    func controllerShouldStopObservingSpinner(_ controller: ActivityIndicatorController) -> Bool { true }

    // MARK: - Private

    func setSeparator() {
        if hasSeparator {
            let separator = UIView()
            separator.backgroundColor = .foreground4
            view.addSubview(separator,
                            constraints:
                            .equal(\.leadingAnchor),
                            .equal(\.trailingAnchor),
                            .equal(\.topAnchor, safeAreaTopAnchor),
                            .equalToConstant(\.heightAnchor, 1))
            self.separator = separator
        }
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        navigationController?.setupContentByTheme()
        UITraitCollection.current = UIApplication.topViewController.traitCollection
    }
}

extension BaseViewController: ActivityIndicatorControllerDelegate {}

extension BaseViewController {
    /// Navigation Bar is above all viewControllers. But notificationSnackBar should be above everything.
    /// So, if naviagtionController exists, add the snack to it.
    func addToView(topSnackBar: SnackBar) {
        if let navigationController {
            topSnackBar.layer.zPosition = .greatestFiniteMagnitude
            navigationController.view.add(snackBar: topSnackBar,
                                          safeAreaTopAnchor: navigationController.safeAreaTopAnchor)
        } else {
            view.add(snackBar: topSnackBar, safeAreaTopAnchor: safeAreaTopAnchor)
        }
    }
}

extension SnackNotificationDisplayer where Self: BaseViewController {
    func setNotificationSnackBar() {
        guard notificationSnackBar == nil else { return }
        notificationSnackBar = SnackBar(position: .top)
        notificationSnackBar.let { addToView(topSnackBar: $0) }
        setTopPaddingInset()
    }

    func setTopPaddingInset() {
        guard notificationSnackBar == nil else { return }
        let topPadding: CGFloat = 8
        if navigationController?.navigationBar.isHidden == false || view.bounds == UIScreen.main.bounds {
            /// This is a case for
            /// 1. a pushed vc
            /// 2. a presented vc that does not obtain navigation bar and occupies every pixel of the screen. Ex: AuthorizationPINViewController.
            /// Diminishing the padding by safeAreaInsets.top of enclosing vc and
            /// adding the notch height.
            notificationSnackBar?.topSnackBarPaddingInset = -(view.safeAreaInsets.top) + UIScreen.main.homeIndicatorInset + topPadding
        } else {
            /// In this case we dont care about the notch.
            /// Usually, case for a bottomshit.
            notificationSnackBar?.topSnackBarPaddingInset = -(view.safeAreaInsets.top) + topPadding
        }
    }
}

extension BaseViewController: SnackBarProvider {}

/// TODO: table view controller, table view node controller
