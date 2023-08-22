//
// Created by Никита Шестаков on 11.03.2023.
//

import Foundation
import SPStorkController

class ChainedDrawerCoordinator<T: ViewControllerProvider>: SceneCoordinator<T>,
                                                           SPStorkControllerDelegate,
                                                           ChainedCoordinator,
                                                           DrawerNavigation {
    var chainParent: ChainedCoordinator? {
        didSet {
            if chainParent == nil {
                if presentingViewController?.presentedViewController == presented {
                    presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    var heightThatFits: CGFloat {
        root.providedViewController.view.sizeThatFits(UIScreen.main.bounds.size).height
    }

    var chainChildren: [AnyCoordinator] = []

    static var drawerWidth: CGFloat? {
        guard UIScreen.main.bounds.width > UIScreen.main.bounds.height else {
            return nil
        }
        return max(375, UIScreen.main.bounds.height)
    }

    static var defaultSize: CGSize {
        .init(width: drawerWidth ?? UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }

    weak var presentingViewController: UIViewController?

    var nc: DrawerNavigationController?
    var presented: UIViewController!
    var backgroundColor: UIColor = .drawerBackground
    var showIndicator = true

    /// Если `true`, то будет обновлять экран, на который презентит перед показом
    /// Полезно когда запускается автоматически, и topLevelVC может поменяться
    var shownAutomatically: Bool { false }

    init(onPresenting viewController: UIViewController, withNavigation: Bool, root: T) {
        self.presentingViewController = viewController
        super.init(root: root)
        if withNavigation {
            let nc = DrawerNavigationController()
            nc.setViewControllers([self.root.providedViewController], animated: false)
            self.nc = nc
            self.presented = nc
        } else {
            self.nc = nil
            self.presented = self.root.providedViewController
        }
    }

    private func makeTransitionDelegate() -> SPStorkTransitioningDelegate {
        let transitionDelegate = SPStorkTransitioningDelegate()
        modifyTransitionDelegate(transitionDelegate)
        return transitionDelegate
    }

    func modifyTransitionDelegate(_ transitionDelegate: SPStorkTransitioningDelegate) {
        transitionDelegate.indicatorMode = .alwaysLine
        transitionDelegate.indicatorColor = .foreground4
        transitionDelegate.backgroundColor = backgroundColor
        transitionDelegate.showIndicator = showIndicator
        transitionDelegate.customWidth = Self.drawerWidth
    }

    override func start() {
        guard let presentingViewController = presentingViewController else { return }
        chainParent?.addChain(self)
        let transitionDelegate = makeTransitionDelegate()
        if let customHeight = transitionDelegate.customHeight {
            transitionDelegate.translateForDismiss = min(transitionDelegate.translateForDismiss,
                                                         customHeight
                                                             - UIScreen.main.homeIndicatorInset
                                                             - 130)
        }
        transitionDelegate.storkDelegate = self
        presented.transitioningDelegate = transitionDelegate
        presented.modalPresentationStyle = .custom
        presented.modalPresentationCapturesStatusBarAppearance = true
        if shownAutomatically {
            SPStorkController.updatePresentingController(modal: presented)
        }
        presentingViewController.present(presented, animated: true, completion: nil)
    }

    override func stop() {
        super.stop()
        _dismiss { [weak self] in
            self?.rootVCDidDismiss()
        }
    }

    func rootVCDidDismiss() {
        presentingViewController?.setNeedsStatusBarAppearanceUpdate()
        delegate?.coordinatorDidStop(self)
        removeSelfChain()
    }

    func layoutPresentingViewControllerSnapshot() {
        SPStorkController.layoutSnapshotView(modal: presented)
    }

    func layoutFullScreenDrawer() {
        root.providedViewController.view.frame.size = Self.defaultSize
        root.providedViewController.view.layoutIfNeeded()
    }

    func changeDrawerHeight(_ newHeight: CGFloat) {
        guard let presentingViewController = presentingViewController else { return }

        UIView.animate(withDuration: 0.2) {
            SPStorkController.changeHeight(newHeight, parent: presentingViewController)
        }
    }

    // MARK: SPStorkControllerDelegate

    public func didDismissStorkBySwipe() {
        rootVCDidDismiss()
    }

    public func didDismissStorkByTap() {
        rootVCDidDismiss()
    }

    func handleEvent(_ event: CoordinatorEvent) {
        chainParent?.handleEvent(event)
    }

    func stop(replacing replacement: ChainedCoordinator) {
        guard let chainParent = chainParent else {
            return guardUnreachable("Drawer should have a chainParent.")
        }
        /// Cant call self.stop because need to have different completion closure.
        super.stop()
        _dismiss { [weak self] in
            self?.rootVCDidDismiss()
            replacement.start(in: chainParent)
        }
    }

    private func _dismiss(completion: @escaping () -> Void) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }
}

class DrawerNavigationController: MainNavController {
    init() {
        super.init(navigationBarClass: DrawerNavigationBar.self, toolbarClass: nil)
        additionalSafeAreaInsets.top = 20
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override var statusBarStyle: UIStatusBarStyle? {
        get { .lightContent }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.tintColor = .black
        navigationBar.titleTextAttributes
            = [.font: UIFont.systemFont(ofSize: 17, weight: .medium),
               .foregroundColor: UIColor.black]
    }
}

class DrawerNavigationBar: UINavigationBar {

    override var frame: CGRect {
        get {
            super.frame
        }
        set {
            var frame = newValue
            frame.size.height = 44
            frame.origin.y = 20
            super.frame = frame
        }
    }
}

/// Use if you have protocol for drawer coordinator and in its extension need access
/// to navigation controller, e.g. PartedContentCoordination
/// You can also use this protocol as an abstraction to any ChainedDrawerCoordinator
protocol DrawerNavigation {
    var nc: DrawerNavigationController? { get set }

    /// Обновляет транзитный вц-снэпшот (который выступает бэкраундом дровера) между родителем и ребенком
    func layoutPresentingViewControllerSnapshot()
}

/// Для дроверов с таблицей, чтобы не копипастить логику adjust (как на русском?) экрана
/// И придти к одному виду вычисления нужного размера экрана
protocol TableDrawerCoordinating: AnySceneCoordinator {
    var tableDrawerHeight: CGFloat? { get }
}

extension TableDrawerCoordinating {
    var tableViewController: TableViewNodeController? {
        assertionCast(anyRoot.providedViewController, to: TableViewNodeController.self)
    }

    var tableView: UITableView? { tableViewController?.tableView }

    /// Все, что над таблицей добавь в contentInset.top, снизу в contentInset.bottom
    /// См. func adjustTableView()
    /// (Если нужно, добавь UIScreen.main.homeIndicatorInset в bottom)
    var tableDrawerHeight: CGFloat? {
        guard let tableView = tableView else { return nil }
        return tableView.contentInset.verticalSum + tableView.contentSize.height
    }
}
