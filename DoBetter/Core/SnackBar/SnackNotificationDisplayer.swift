//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

/// A vc that actually displays the top snack bar notifications should conform to this.
/// Use case: when have a vc that does not fill the top part of the screen, but want to show the notification in the top part of the screen.
protocol SnackNotificationDisplayer: AnyObject {
    var notificationSnackBar: SnackBar? { get }
    var notificationModel: CommonSnack.Model? { get set }
    func setNotificationSnackBar()
    /// Setting padding based on configuration of navigationBar.
    /// safeAreaLayoutGuide includes both notch and navigation bar.
    /// However, we need to show the notificationSnack on the navigationBar, not below it.
    func setTopPaddingInset()
}

/// Protocol for child vcs.
protocol SnackNotificationDisplayLogic {
    func showNotify(with model: CommonSnack.Model, allowRepeatedModel: Bool, hideAfter: Double)
    static func showNotify(on parent: SnackNotificationDisplayer, with model: CommonSnack.Model,
                           allowRepeatedModel: Bool, hideAfter: Double)
}

extension SnackNotificationDisplayLogic {
    static func showNotify(on parent: SnackNotificationDisplayer, with model: CommonSnack.Model, allowRepeatedModel: Bool, hideAfter: Double) {
        /// Case for
        /// 1. Multiple same information notification snacks (allowRepeatedModel set to true)
        /// OR 2. For a notification snack with different information than currently displayed snack (allowRepeatedModel set to true or false).
        if allowRepeatedModel || model != parent.notificationModel {
            let snack = SnackCreator.hidingSnack(parent: parent, with: model)
            snack.show()
            Self.hide(snack: snack, hideAfter: hideAfter)
            /// If currently a snack is shown and allowRepeatedModel is false and the snack has the same info as currently displayed snack.
            /// Hiding shown snack and fastly showing new snack.
        } else if let snackToHide = parent.notificationSnackBar?.snacks.first(where: \.state, is: .shown) {
            Self.hide(snack: snackToHide, hideAfter: 0, hidingAnimationDuration: 0.5) { [weak parent] in
                guard let parent = parent else { return }
                let snack = SnackCreator.hidingSnack(parent: parent, with: model)
                snack.show(with: 0.5)
                Self.hide(snack: snack, hideAfter: hideAfter)
            }
        }
    }

    /// Hiding a snack after some time
    ///
    /// - Parameters:
    ///   - snack: a snack to hide
    ///   - hideAfter: period after which the snack starts to hide
    ///   - hidingAnimationDuration: duration of hiding process.
    ///   - completion: closure which is getting called after the snack is hidden.
    static func hide(snack: Snack, hideAfter: Double = 3,
                     hidingAnimationDuration: TimeInterval? = nil,
                     completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + hideAfter) { [weak snack] in
            snack?.hide(with: hidingAnimationDuration) { [weak snack] _ in
                /// hideCompletion of a snack
                snack?.hideCompletion?(true)
                snack?.hideCompletion = nil
                completion?()
            }
        }
    }
}

/// Extension with logic for displaying topSnack Notifications from child VCs in their parents.
/// It makes possible to display notifications for in the top part of the whole screen, not the top part of a child VC.
/// Ex.: "Скопировано", "Ошибка подключения"
/// How to use:
/// 1. Mark Parent VC with SnackNotificationDisplayer
/// 2. Call showNotify or showNotifySmth in the child.
extension UIViewController: SnackNotificationDisplayLogic {
    /// VC that should show top snack.
    var closestVCWithNotificationSnack: SnackNotificationDisplayer {
        var vc: UIViewController? = self

        /// Finding closest VC in parent hierarchy (or self) that is Full Screen VC.
        while vc != nil {
            if let snackNotificationVC = vc as? SnackNotificationDisplayer {
                if let notificationSnackBar = snackNotificationVC.notificationSnackBar {
                    return snackNotificationVC
                } else {
                    /// Create and add to view a top snack bar if it was not created before.
                    snackNotificationVC.setNotificationSnackBar()
                    return snackNotificationVC
                }
            }
            vc = vc?.parent
        }
        /// If didnt manage to find a SnackNotificationDisplayer in vc hierarchy, use window.
        /// It is not encouraged to use the window.
        let mainWindow = AppCoordinator.shared.window
        mainWindow.setNotificationSnackBar()

        /// Тут должен был быть ассерт, если бы эти снэки были сделаны нормально, но
        /// если вы задумаете, например, чтобы снэки отображались для таббед экрана,
        /// то так или иначе столкнетесь со следующими проблемами:
        /// 1) Таббед не является парентом для экранов из моделек
        /// 2) BaseViewController addToView(topSnackBar:) полагается на navigationController,
        /// и от этого зависит местоположение снэка, а значит поведение в таббед экранах непредсказуемо
        /// 3) Весь UIViewController подписан на SnackNotificationDisplayLogic и реализует методы в экстенше,
        /// а значит, будьте добры, распробуйте прелесть статической диспетчеризации
        ///
        /// Поздравляю, выстрел в ногу сделан, а значит можете отрефачить все снэки, чтобы это
        /// можно было нормально переопределить и эта штука была универсальна, а не для пары основных кейсов.
        /// Не забудьте найти отважного тестировщика, который согласится посмотреть примерно все приложение,
        /// потому что эта говна есть примерно везде.
        Logger.common.warning("You need to conform some parent vc to SnackNotificationDisplayer")
        return mainWindow
    }

    /// Show top snack
    func showNotify(with model: CommonSnack.Model, allowRepeatedModel: Bool = false, hideAfter: Double = 3) {
        Self.showNotify(on: closestVCWithNotificationSnack, with: model, allowRepeatedModel: allowRepeatedModel, hideAfter: hideAfter)
    }

    static func showOnMainWindow(with model: CommonSnack.Model, allowRepeatedModel: Bool = false, hideAfter: Double = 3) {
        let mainWindow = AppCoordinator.shared.window
        mainWindow.setNotificationSnackBar()
        Self.showNotify(on: mainWindow, with: model, allowRepeatedModel: allowRepeatedModel, hideAfter: hideAfter)
    }
}

enum SnackCreator {
    static func hidingSnack(parent: SnackNotificationDisplayer, with model: CommonSnack.Model) -> Snack {
        let snack = CommonSnack(removeOnPan: true)
        parent.notificationSnackBar?.snacks.append(snack)
        snack.apply(model: model)
        parent.notificationModel = model
        /// Passing a completion which will be used only one time. There are 2 ways of this completion getting called.
        /// Note, it should be called only once!
        /// 1. After some time (5 sec) it getting called automatically by us.
        /// 2. Getting called from snack when user swipes away the snack.
        /// After the call, it must be deallocated (set to nil).
        snack.hideCompletion = { [weak parent, weak snack] _ in
            guard let snack = snack else { return }
            parent?.notificationSnackBar?.snacks.remove(snack)
            parent?.notificationModel = nil
        }
        return snack
    }
}

class MainUIWindow: UIWindow, SnackNotificationDisplayer {
    var notificationSnackBar: SnackBar?
    var notificationModel: CommonSnack.Model?

    func setNotificationSnackBar() {
        guard notificationSnackBar == nil else { return }
        notificationSnackBar = SnackBar(position: .top)
        notificationSnackBar.let { add(snackBar: $0) }
        setTopPaddingInset()
    }
    func setTopPaddingInset() {
        notificationSnackBar?.topSnackBarPaddingInset = UIScreen.main.notchInset
    }
}

/// Размеры экраны можно посмотреть здесь: https://www.ios-resolution.com/
public extension UIScreen {

    func isSmall() -> Bool {
        bounds.width < 375
    }

    func isSmallest() -> Bool {
        isSmall() && bounds.size.height < 568
    }

    func isBig() -> Bool {
        bounds.height > 667
    }

    /// По какой-то исторической причине, isSmall() вычисляется по ширине bounds, а isBig() — по высоте;
    /// Это не всегда то, что мы ожидаем, когда пытаемся уместить контент в ширину.
    /// Так, например, 12 mini считается isBig, a SE 2nd gen — нет, хотя по ширине они равнозначны.
    func isWide() -> Bool {
        bounds.width >= 414
    }

    var homeIndicatorInset: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
    }

    var notchInset: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
    }

    var statusBarHeight: CGFloat {
        UIApplication.shared.statusBarFrame.height
    }
}
