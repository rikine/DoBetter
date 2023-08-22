//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import UIKit
import ViewNodes

protocol TableDisplayLogic: DisplayLogic {
    /// Отображает таблицу:
    /// -- Без дифера, если sections пусты
    /// -- С диффером, иначе
    func displayTableAuto(_ viewModel: Table.Data.ViewModel)
    /// Отображение таблицы
    func displayTable(_ viewModel: Table.Data.ViewModel, withDiffer: Bool)
    /// Немного мертвый метод, который пытались юзать до появления диффера
    func displayTableAppend(_ viewModel: Table.Data.AppendViewModel)

    func displayTableHeader(_ viewModel: ViewAnyModel?)
    func displayTableFooter(_ viewModel: ViewAnyModel?)
    func displayStickyHeader<T: ViewAnyModel>(_ viewModel: T?)

    func didSelectRowAt(indexPath: IndexPath, payload: CellModelPayload?)
    func displayNextPage(_ viewModel: Table.NextPage.ViewModel)
}

extension TableDisplayLogic {
    func displayNextPage(_ viewModel: Table.NextPage.ViewModel) {}

    func displayTable(_ viewModel: Table.Data.ViewModel) {
        displayTable(viewModel, withDiffer: false)
    }

    func displayPlaceholder(_ viewModel: ViewAnyModel) {
        displayTable(.init(sections: [], emptyDataPlaceholder: viewModel))
    }
}

protocol TableDisplaying: Displaying, TableDisplayLogic {}

extension TableDisplaying {
    var tableInteractor: TableBusinessLogic? { interactor as? TableBusinessLogic }

    func didSelectRowAt(indexPath: IndexPath, payload: CellModelPayload?) {
        tableInteractor?.didSelectRow(.init(indexPath: indexPath, payload: payload))
    }

    func displayNextPage(_ viewModel: Table.NextPage.ViewModel) {
        tableInteractor?.loadV2(.nextPage)
    }
}

// swiftlint:disable type_body_length
class TableViewController: BaseViewController,
                           ErrorDisplaying,
                           ExtendedTableViewDelegate,
                           UITableViewDataSource,
                           DifferUpdatable {

    var sections: [Table.SectionViewModel] = []
    var cellModelTypes: [CellViewAnyModel.Type] { [] }

    var preventedFromDrag: IndexPath?
    /// Флаг наличия пагинации у таблицы
    var hasDefaultPaging: Bool { false }
    var numberOfRowsBeforeNextPageTrigger = 5

    @IBOutlet var tableView: UITableView! {
        didSet {
            if #available(iOS 15.0, *) {
                tableView.isPrefetchingEnabled = false
                tableView.sectionHeaderTopPadding = 0
            }
            tableView.tableFooterView = UIView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.register(models: cellModelTypes)
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
        }
    }

    var differUpdatableView: UITableView? { tableView }

    /// The headers only remain fixed (floating) when the UITableView.Style property  is set to .plain.
    /// If you have it set to .grouped, the headers will scroll up with the cells (will not float).
    var tableViewStyle: UITableView.Style { .plain }

    var shadow: Shadow? {
        didSet {
            _setupShadow()
        }
    }

    var navBarBottomSeparator: Table.NavBarBottomSeparator? { nil }
    private var isNavbarBottomSeparatorShouldHideOnTop: Bool { navBarBottomSeparator?.behavior == .hideOnTop }
    private var separatorHeight: CGFloat { navBarBottomSeparator?.height ?? 0 }

    var stickyHeader: View?
    var stickyHeaderHeight: CGFloat { stickyHeader?.bounds.height ?? 0 }

    // iOS 10: topLayoutGuide.bottomAnchor doesn't work well for embedded view controllers,
    // so, we can override topAnchor if needed
    var topAnchor: NSLayoutYAxisAnchor { safeAreaTopAnchor }

    private var _shadowHeightConstraint: NSLayoutConstraint!
    private lazy var _shadowView: UIView = {
        let shadowView = UIView()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.alpha = 0
        _shadowHeightConstraint = view.addSubview(shadowView,
                                                  constraints:
                                                  .equalToConstant(\.heightAnchor, shadow?.radius ?? 0),
                                                  .equal(\.leadingAnchor),
                                                  .equal(\.topAnchor, topAnchor),
                                                  .equal(\.trailingAnchor))[0]
        return shadowView
    }()

    private lazy var _separatorView: UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.alpha = isNavbarBottomSeparatorShouldHideOnTop ? 0 : 1.0
        view.addSubview(separatorView,
                        constraints:
                        .equalToConstant(\.heightAnchor, separatorHeight),
                        .equal(\.leadingAnchor),
                        .equal(\.topAnchor, topAnchor),
                        .equal(\.trailingAnchor))
        return separatorView
    }()

    private func showHideAnimation(for view: UIView, showHideFlagKeyPath: KeyPath<TableViewController, Bool>) {
        UIView.animate(withDuration: Animation.Duration.default,
                       delay: 0,
                       options: .beginFromCurrentState, animations: { [weak self] in
            guard let self else { return }
            view.alpha = self[keyPath: showHideFlagKeyPath] ? 0 : 1
        })
    }

    private var _isShadowHidden: Bool = true {
        didSet {
            guard _isShadowHidden != oldValue else {
                return
            }
            showHideAnimation(for: _shadowView, showHideFlagKeyPath: \._isShadowHidden)
        }
    }

    private var _isSeparatorHidden: Bool = true {
        didSet {
            guard _isSeparatorHidden != oldValue else {
                return
            }
            showHideAnimation(for: _separatorView, showHideFlagKeyPath: \._isSeparatorHidden)
        }
    }

    private let _gradientLayer = CAGradientLayer()

    var enableScrollAfterDiffer: Bool { true }
    var isDifferUpdateInProgress = false
    var pendingViewModel: Table.Data.ViewModel?

    var isTableHeaderViewVisible: Bool {
        guard let tableHeaderView = tableView.tableHeaderView else { return false }
        let currentYOffset = tableView.contentOffset.y
        let headerHeight = tableHeaderView.frame.size.height
        return currentYOffset < headerHeight
    }

    private func _setupShadow() {
        _shadowView.isHidden = shadow == nil
        guard let shadow = shadow else {
            return
        }
        _gradientLayer.colors = [shadow.color.withAlphaComponent(CGFloat(shadow.opacity)),
                                 shadow.color.withAlphaComponent(0)].map(\.cgColor)

        _gradientLayer.frame = CGRect(origin: view.bounds.origin,
                                      size: CGSize(width: view.layer.bounds.width,
                                                   height: shadow.radius))
        _shadowHeightConstraint.constant = shadow.radius
        _shadowView.layer.insertSublayer(_gradientLayer, at: 0)
    }

    private func _setupSeparator() {
        guard let navBarBottomSeparator else { return }
        _separatorView.backgroundColor = navBarBottomSeparator.color
        _isSeparatorHidden = isNavbarBottomSeparatorShouldHideOnTop
    }

    public func makeTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: tableViewStyle)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.estimatedSectionHeaderHeight = 0
        return tableView
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutTableHeader()
        layoutTableFooter()
        _setupShadow()
        _setupSeparator()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tableView.reloadData()
    }

    func layoutTableHeader() {
        guard let header = tableView.tableHeaderView else { return }
        let height = header.sizeThatFits(CGSize(width: tableView.bounds.width, height: .greatestFiniteMagnitude)).height
        header.frame.size.height = height
        header.frame.size.width = tableView.bounds.width
    }

    func layoutTableFooter() {
        guard let footer = tableView.tableFooterView else { return }
        footer.frame.size = footer.sizeThatFits(CGSize(width: tableView.bounds.width, height: .greatestFiniteMagnitude))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectRow()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let inset = tableView.adjustedContentInset
        let isHidden = scrollView.contentOffset.y + inset.top <= 0

        _isShadowHidden = isHidden
        if isNavbarBottomSeparatorShouldHideOnTop {
            _isSeparatorHidden = isHidden
        }
    }

    // FIXME: if we won't implement it here, child's implementation is not called
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    func displayTableHeader(_ viewModel: ViewAnyModel?) {
        tableView.tableHeaderView = viewModel.flatMap { $0.makeView() }
        layoutTableHeader()
    }

    /// Футер должен быть либо пустой (устанавливается в didSet таблицы), либо из модели, но не nil,
    /// поэтому guard убирать нельзя. Иначе таблица будет показывать пустые ячейки, в т.ч. поверх плейсхолдера
    func displayTableFooter(_ viewModel: ViewAnyModel?) {
        guard let viewModel = viewModel else { return }
        tableView.tableFooterView = viewModel.makeView()
        layoutTableFooter()
    }

    func displayStickyHeader<T: ViewAnyModel>(_ viewModel: T?) {
        guard let stickyHeader = stickyHeader else { return }
        guard T.viewAnyType.self == type(of: stickyHeader) else {
            assertionFailure("""
                             Sticky headers type: \(type(of: stickyHeader))
                             must be the same as the viewModel's view type: \(T.viewAnyType.self)
                             """)
            return
        }
        viewModel?.setupAny(view: stickyHeader)
    }

    func displayTableAuto(_ viewModel: Table.Data.ViewModel) {
        /// Without differ if current sections have not cells or section to update have not cells.
        let withDiffer = !sections.allSatisfy(\.cells.isEmpty, to: true)
            && !viewModel.sections.allSatisfy(\.cells.isEmpty, to: true)
        displayTable(viewModel, withDiffer: withDiffer)
    }

    func displayTable(_ viewModel: Table.Data.ViewModel, withDiffer: Bool) {
        withDiffer
            ? displayTableWithDiffer(viewModel)
            : displayTableWithoutDiffer(viewModel)

        if viewModel.sections.allCellsAreEmpty {
            let stopper = viewModel.emptyDataPlaceholder?.makeView()
            tableView.backgroundView = stopper
        } else {
            tableView.backgroundView?.removeFromSuperview()
            tableView.backgroundView = nil
        }
    }

    func displayTableWithoutDiffer(_ viewModel: Table.Data.ViewModel) {
        /// Пояснение зачем это находится в начале функции `displayTableWithDiffer(_:)`
        loadViewIfNeeded()

        guard let tableView = tableView else { return }
        let isEmpty = viewModel.sections.allCellsAreEmpty
        let showTableHeader: Bool = !isEmpty || viewModel.showHeaderIfTableIsEmpty
        let showTableFooter: Bool = !isEmpty || viewModel.showFooterIfTableIsEmpty

        if isEmpty {
            let view = makePlaceholder(from: viewModel.emptyDataPlaceholder)
            tableView.backgroundView = view
            sections = []
        } else {
            tableView.backgroundView = nil
            sections = viewModel.sections
        }

        displayTableHeader(showTableHeader ? viewModel.header : nil)
        displayTableFooter(showTableFooter ? viewModel.footer : nil)

        viewModel.scrollTo.let {
            scroll(to: $0.withoutAnimation)
        }
        tableView.reloadData { tableView in
            tableView.extendedDelegate?.onReload(tableView)
            viewModel.scrollTo.let {
                tableView.layoutIfNeeded()
                self.scroll(to: $0)
            }
        }
    }

    func makePlaceholder(from model: ViewAnyModel?) -> UIView? {
        guard let view = model?.makeView() else { return nil }
        if let view = view as? View {
            view.paddingInsets.bottom += tableView.contentInset.bottom
        }
        return view
    }

    func displayTableWithDiffer(_ viewModel: Table.Data.ViewModel) {
        /// В Crashlytics начали появляться ошибки на строчке с обращением к таблице (`tableView.isScrollEnabled = true`)
        /// Этот Экран на сторибордах, убрать его со сторибордов == 100500 сторипоинтов,
        /// поэтому просто вставим сюда вызов низней функции и будем надеяться что все хорошо
        loadViewIfNeeded()

        tableView.isScrollEnabled = enableScrollAfterDiffer
        updateViewWithDiffer(viewModel)
    }

    func scroll(to scroll: Table.Scroll) {
        switch scroll.position {
        case .point(let point):
            tableView.setContentOffset(point, animated: scroll.animated)
        case .pointAccountingInset(var point):
            point.y -= tableView.adjustedContentInset.top
            tableView.setContentOffset(point, animated: scroll.animated)
        case .row(let indexPath):
            tableView.scrollToRow(at: indexPath, at: .top, animated: scroll.animated)
        }
    }

    func displayTableAppend(_ viewModel: Table.Data.AppendViewModel) {

        func update() {
            if let lastSectionAppend = viewModel.lastSectionViewModel {
                if var lastSection = sections.last {
                    let indexes: [IndexPath] = (0..<lastSectionAppend.count).map {
                        IndexPath(item: lastSection.cells.count + $0, section: sections.count - 1)
                    }
                    lastSection.cells += lastSectionAppend
                    sections[sections.count - 1] = lastSection
                    tableView.insertRows(at: indexes, with: .fade)
                } else {
                    assert(false, "Nowhere to append")
                }
            }
            if let newSections = viewModel.newSectionsViewModels, !newSections.isEmpty {
                let begin = sections.count
                let end = begin + newSections.count
                sections.append(contentsOf: newSections)
                tableView.insertSections(IndexSet(integersIn: (begin..<end)), with: .fade)
            }
        }

        tableView.performBatchUpdates(update)

    }

    func displayError(_ viewModel: ErrorHandling.ViewModel) {
        deselectRow()
        if tableView.contentOffset.y < tableView.contentInset.top {
            scroll(to: .zero)
        }
        displayDefaultError(viewModel)
    }

    // Without these implementations methods from ErrorDisplaying extension will be called in subclasses.
    func onDismissErrorAlert(_ viewModel: ErrorHandling.ViewModel) {}

    func exit() {}

    // MARK: - Table Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (self as? TableDisplayLogic)?.didSelectRowAt(indexPath: indexPath, payload: payload(at: indexPath))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if hasDefaultPaging, tableView.numberOfRows(after: indexPath) == numberOfRowsBeforeNextPageTrigger {
            (self as? TableDisplayLogic)?.displayNextPage(.init())
        }
    }

    /// Implementation is required, otherwise protocol extension implementations will be called
    func tableView(_ tableView: UITableView, willUpdateWithoutReloading cell: UITableViewCell, forRowAt indexPath: IndexPath) {}

    func onUpdateWithoutReload(_ tableView: UITableView) {}

    func onReload(_ tableView: UITableView) {}

    override func controllerShouldStartObservingSpinner(_ controller: ActivityIndicatorController) -> Bool {
        // This override is here until we complete migration to `ActivityIndication` instead of
        // notification-based activity indicators.
        false
    }

    override func controllerShouldStopObservingSpinner(_ controller: ActivityIndicatorController) -> Bool {
        // This override is here until we complete migration to `ActivityIndication` instead of
        // notification-based activity indicators.
        false
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        _headerFooterView(for: \.footer, showHeaderFooterKeyPath: \.showFooterIfSectionIsEmpty, sectionNumber: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        _headerFooterHeight(for: \.footer, showHeaderFooterKeyPath: \.showFooterIfSectionIsEmpty, sectionNumber: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        _headerFooterView(for: \.header, showHeaderFooterKeyPath: \.showHeaderIfSectionIsEmpty, sectionNumber: section)
    }

    // TODO TECH_SPRINT remove from superclass (ЗОЧЕМ???)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        _headerFooterHeight(for: \.header, showHeaderFooterKeyPath: \.showHeaderIfSectionIsEmpty, sectionNumber: section)
    }

    private func _headerFooterView(
        for headerFooterKeyPath: KeyPath<Table.SectionViewModel, ViewAnyModel?>,
        showHeaderFooterKeyPath: KeyPath<Table.SectionViewModel, Bool>,
        sectionNumber: Int
    ) -> UIView? {
        guard let section = sections[optional: sectionNumber],
              let view = section[keyPath: headerFooterKeyPath]?.makeView(),
              !section.cells.isEmpty || section[keyPath: showHeaderFooterKeyPath]
        else { return nil }
        view.frame.size = view.sizeThatFits(CGSize(width: tableView.bounds.size.width, height: .greatestFiniteMagnitude))
        return view
    }

    private func _headerFooterHeight(
        for headerFooterKeyPath: KeyPath<Table.SectionViewModel, ViewAnyModel?>,
        showHeaderFooterKeyPath: KeyPath<Table.SectionViewModel, Bool>,
        sectionNumber: Int
    ) -> CGFloat {
        guard sectionNumber < sections.count else { return UITableView.automaticDimension }
        let section = sections[sectionNumber]
        guard section[keyPath: headerFooterKeyPath] != nil,
              !section.cells.isEmpty || section[keyPath: showHeaderFooterKeyPath]
            // При использовании таблицы с UITableView.Style = grouped у хедера и футера секций
            // появляются дополнительные инсеты. Избавится от них можно
            // если в этом методе возвращать не 0, а GFloat.leastNormalMagnitude
        else { return CGFloat.leastNormalMagnitude }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        nil
    }

    // MARK: - Table Data Source

    func cellModel(at indexPath: IndexPath) -> CellViewAnyModel {
        sections[indexPath]
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].cells.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withModel: cellModel(at: indexPath), for: indexPath)
        modify(cell: cell, forRowAt: indexPath)
        return cell
    }

    /// Method to bind cell actions
    public func modify(cell: UITableViewCell, forRowAt indexPath: IndexPath) {}

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        sections[optional: indexPath]?.estimatedHeight ?? tableView.estimatedRowHeight
    }

    func payload(at indexPath: IndexPath) -> CellModelPayload? {
        (sections[optional: indexPath] as? AnyPayloadableCellModel)?.payload
    }

    private func deselectRow() {
        guard let selected = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: selected, animated: true)
    }
}
