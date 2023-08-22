//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit
import ViewNodes

class TableViewNodeController: TableViewController, ActivityIndicationDisplaying {

    /// Любая вью, которая находится над таблицей. По дефолту используется навигейшн бар бэкграунд.
    var headlineView: View!

    /// Враппер для вью снизу, по дефолту стоит паддинг homeIndicatorInsets
    /// Если нужен не VStack, то просто добавьте в bottomView то, что нужно
    /// Все инсеты настроены по дефолту, поэтому переопределять additionalBottomContentInset не нужно
    var bottomViewStack: VStack?
    /// Вью снизу, по дефолту пустая вью
    var bottomView: View?

    /// Флаг хедлайн вью (вью над таблицей)
    var isCustomHeadlineView: Bool { false }
    private var headlineViewHeight: CGFloat { isCustomHeadlineView ? headlineView.bounds.height : defaultHeadlineViewHeight }

    /// Флаг, что вьюха снизу нужна
    var isBottomViewNeeded: Bool { false }
    /// Если стэк не нужен, скрыт или nil, то возвращем nil, чтобы проставить инсеты от safeArea
    var bottomViewHeight: CGFloat? {
        isBottomViewNeeded && bottomViewStack?.isHidden == false ? bottomViewStack?.bounds.height : nil
    }

    /// Высота навигейшн бар бэкграунда
    var defaultHeadlineViewHeight: CGFloat { view.safeAreaInsets.top }

    /// Сумма высот всех вью над таблицей
    var totalTopHeight: CGFloat { headlineViewHeight + stickyHeaderHeight }

    /// Use if want to add toolbar using Nodes.
    var needsToolbar: Bool { false }

    var tableViewWrapper: View!

    /// Refresh control above the table view during pull-to-refresh
    var isRefreshControlNeeded: Bool { true }

    var isScrollEnabled: Bool = true { didSet { _updateTableScroll() } }
    var isRefreshing: Bool = false { didSet { _updateTableScroll() } }
    override var enableScrollAfterDiffer: Bool { !isRefreshing && isScrollEnabled }

    var additionalTopContentInset: CGFloat { 0 }
    var additionalBottomContentInset: CGFloat { bottomSnackBar.containerHeight }
    /// При nil в adjustTableView проставятся safeArea инсеты
    var bottomForceInset: CGFloat? { bottomViewHeight }

    private func _updateTableScroll() {
        tableView.isScrollEnabled = enableScrollAfterDiffer
    }

    var activityIndicationBackgroundColor: UIColor { ActivityIndicatorController.backgroundColor }

    @objc
    func refreshControlChanged() {
        tableView.panGestureRecognizerTranslation.y += 60
        if !tableView.isDragging {
            refresh()
        }

        if tableView.refreshControl?.isRefreshing == false {
            scroll(to: .zero)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.isRefreshing {
            refresh()
        }
    }

    func displayActivityIndication(_ viewModel: ActivityIndication.ViewModel) {
        displayDefaultActivityIndication(viewModel)
        guard !viewModel.isShown && !viewModel.ignoreRefreshControl && tableView.refreshControl != nil else {
            self.isRefreshing = false
            return
        }

        if let refreshControl = self.tableView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            if parent == nil {
                scroll(to: Table.Scroll.zero.withoutAnimation)
            } else if refreshControl.frame.height <= 60 {
                scroll(to: Table.Scroll.zero.withAnimation)
            }
        }
        isRefreshing = false
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil, let tableView = tableView, tableView.contentOffset.y < 0 {
            tableView.refreshControl?.endRefreshing()
            scroll(to: Table.Scroll.zero.withoutAnimation)
        }
    }

    func refresh() {
        isRefreshing = true
    }

    override func scroll(to scroll: Table.Scroll) {
        guard !tableView.isRefreshing else { return }
        super.scroll(to: scroll)
    }

    override func loadView() {
        tableView = makeTableView()
        if isRefreshControlNeeded {
            tableView.setRefreshControl(style: .none, target: self, action: #selector(refreshControlChanged))
        }
        view = makeView(with: tableView)
    }

    override func makeTableView() -> UITableView {
        let tableView = super.makeTableView()
        tableView.separatorColor = .foreground4
        return tableView
    }

    func makeView(with tableView: UITableView) -> View {
        ZStack().config(backgroundColor: .background2).content {
            tableViewWrapper = UIViewWrapper(tableView).height(.fill)
            VStack().position(.top).content {
                headlineView = makeHeadlineView()
                stickyHeader = makeStickyHeader()
            }
            bottomViewStack = makeBottomViewWrapper()
        }
    }

    /// Оверрайдите этот метод в своей сцене, если у вас есть кастомная вью, заменяющая дефолтный нав бар.
    func makeHeadlineView() -> View {
        makeNavBarBackground()
    }

    func makeStickyHeader() -> View {
        View()
    }

    func makeBottomView() -> View {
        View()
    }

    /// При дефолтном нав баре создается бэкграунд для него.
    private func makeNavBarBackground() -> View {
        View().background(color: .background2)
    }

    func makeBottomViewWrapper() -> VStack {
        VStack()
                .padding(.bottom(UIScreen.main.homeIndicatorInset)) /// Используется чаще всего
                .position(.bottom)
                .content {
                    bottomView = makeBottomView()
                }.hidden(!isBottomViewNeeded)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        assert(headlineView != nil, "Call super.loadView() my dude")
        // Устанавливаем высоту только для дефолтного хелдайна (нав бар бэкграунда),
        // потому что кастомная высота будет задаваться в моделях кастомных хедлайнов
        if !isCustomHeadlineView {
            headlineView.height(defaultHeadlineViewHeight)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustTableView()
    }

    func adjustTableView() {
        guard !tableView.isRefreshing else { return }

        let topInset = totalTopHeight
        let bottomInset = view.safeAreaInsets.bottom

        tableView.contentInset.top = topInset + additionalTopContentInset
        tableView.contentInset.bottom = (bottomForceInset ?? bottomInset) + additionalBottomContentInset

        if viewWasNeverAppeared {
            tableView.contentOffset.y = -tableView.contentInset.top
        }
        tableView.scrollIndicatorInsets = tableView.contentInset

        tableView.refreshControl?.frame = navigationController?.navigationBar.frame ?? .zero
    }
    /// Для оверайда в дочерних классах
    var activityIndicatorSourceView: UIView? { navigationController?.view }
}
