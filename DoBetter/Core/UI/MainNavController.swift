//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation


//
//  MainNavController.swift
//  VisionInvest
//
//  Created by Sergej Jaskiewicz on 13/07/2017.
//  Copyright © 2017 openbank. All rights reserved.
//

import UIKit

@objc protocol NavigationControllerContentChangesDelegate {
    func didPushViewController(_ viewController: UIViewController)

    func didPopViewController(_ viewController: UIViewController)

    func didSetViewControllers(_ viewControllers: [UIViewController])
}

class MainNavController: UINavigationController {
    let observers = WeakArray<NavigationControllerContentChangesDelegate>()

    static let defaultStatusBarStyle: UIStatusBarStyle = .lightContent

    override func awakeFromNib() {
        super.awakeFromNib()

        navigationBar.setTransparent(true)
    }

    var statusBarStyle: UIStatusBarStyle? = MainNavController.defaultStatusBarStyle

    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
            ?? topViewController?.preferredStatusBarStyle
            ?? MainNavController.defaultStatusBarStyle
    }

    // iOS 9 fix for back button color
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.tintAdjustmentMode = .normal
        navigationBar.barTintColor = .accent
        navigationBar.backgroundColor = .accent
        navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .accent
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
    }

    // MARK: Delegates
    func addDelegate(_ delegate: NavigationControllerContentChangesDelegate) {
        observers.append(delegate)
    }

    func removeDelegate(_ delegate: NavigationControllerContentChangesDelegate) {
        observers.remove(delegate)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        observers.forEach { $0.didPushViewController(viewController) }
    }

    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: animated).also { controller in
            observers.forEach { $0.didPopViewController(controller) }
        }
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        observers.forEach { $0.didSetViewControllers(viewControllers) }
    }

    @discardableResult
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        super.popToViewController(viewController, animated: animated).also { controllers in
            observers.forEach { observer in
                controllers.forEach { controller in
                    observer.didPopViewController(controller)
                }
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupContentByTheme()
    }
}

extension UINavigationController {
    var isTransitionInProgress: Bool {
        transitionCoordinator != nil
    }

    func performAfterTransition(_ action: @escaping VoidClosure) {
        if isTransitionInProgress {
            transitionCoordinator?.animate(alongsideTransition: nil) { _ in
                action()
            }
        } else {
            action()
        }
    }

    func setupDefaultContent(_ color: UIColor = .background2) {
        navigationBar.barTintColor = color
        navigationBar.shadowImage = UIImage()
    }

    func setupContentByTheme() {
        if #available(iOS 12.0, *) {
            traitCollection.userInterfaceStyle == .dark ? setupLightContent() : setupDarkContent()
        } else {
            setupDarkContent()
        }
    }

    @available(*, deprecated, message: "Use setupContentByTheme() instead")
    func setupLightContent() {
        setBarLightContent()
        (self as? MainNavController)?.statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }

    @available(*, deprecated, message: "Use setupContentByTheme() instead")
    func setupDarkContent() {
        setBarDarkContent()
        (self as? MainNavController)?.statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }

    func setBarLightContent() {
        if navigationBar.titleTextAttributes == nil {
            navigationBar.titleTextAttributes = [:]
        }
        navigationBar.titleTextAttributes?[.foregroundColor] = #colorLiteral(red: 0.9686532617, green: 0.9749757648, blue: 0.9750954509, alpha: 1)
    }

    func setBarDarkContent() {
        if navigationBar.titleTextAttributes == nil {
            navigationBar.titleTextAttributes = [:]
        }
        navigationBar.titleTextAttributes?[.foregroundColor] = #colorLiteral(red: 0.1803303957, green: 0.1801795065, blue: 0.1925967336, alpha: 1)
    }
}

public extension UINavigationBar {

    /// Sets the bar's `backgroundImage` and `shadowImage` to an empty dummy
    /// image which lets it be transparent.
    func setTransparent(_ isTransparent: Bool) {

        let backgroundImage = isTransparent ? UIImage() : nil
        let shadowImage = isTransparent ? UIImage() : nil

        setBackgroundImage(backgroundImage, for: .default)
        self.shadowImage = shadowImage
    }
}

class BackBarButtonItem: UIBarButtonItem {

    ///https://developer.apple.com/forums/thread/653913
    @available(iOS 14.0, *)
    override var menu: UIMenu? {
        get { super.menu }
        set {
            /* Don't set the menu here */
            /* super.menu = menu */
        }
    }
}

extension UIBarButtonItem {
    open override func titleTextAttributes(for state: UIControl.State) -> [NSAttributedString.Key: Any]? { super.titleTextAttributes(for: state) }
}
