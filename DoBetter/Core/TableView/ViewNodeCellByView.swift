//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit
import ViewNodes

/// Пример использования:
///
/// class YourCell: ViewNodeCellByView<YourView> {
///     typealias Model = CellViewModelByView<YourView.Model, YourCell>
/// }
///
/// Где,
/// - `YourView` - вьюха, подписанная под `Initializable`
/// - `YourView.Model` - моделька данной вьюхи
///
class ViewNodeCellByView<MainView: InitializableView>: ViewNodeCell {
    var wrapperView: View!
    var mainView: MainView!
    var padding: UIEdgeInsets { .zero }

    override func makeView() -> View {
        wrapperView = View().background(color: .clear).content {
                    mainView = MainView()
                }
                .padding(padding)
        return wrapperView
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        mainView.prepareForReuse()
    }
}

struct CellViewModelByView<MainViewModel: ViewModel,
                          WrapperCell: ViewNodeCellByView<MainViewModel.ViewType>>: CellViewModel {
    public var mainViewModel: MainViewModel
    public let backgroundColor: UIColor?
    public let padding: UIEdgeInsets?

    public init(_ mainViewModel: MainViewModel,
                backgroundColor: UIColor? = .clear,
                padding: UIEdgeInsets? = nil) {
        self.mainViewModel = mainViewModel
        self.backgroundColor = backgroundColor
        self.padding = padding
    }

    /// Инит для красивого мапа: .map(Foo.Cell.Model.init)
    public init(_ mainViewModel: MainViewModel) {
        self.init(mainViewModel, backgroundColor: nil, padding: nil)
    }

    // MARK: - CellViewModel
    public var estimatedHeight: CGFloat? {
        guard let mainEstimatingHeight = mainViewModel as? EstimatingHeight else { return nil }
        return mainEstimatingHeight.estimatedHeight
            + (padding?.top ?? 0)
            + (padding?.bottom ?? 0)
    }

    public func setup(cell: WrapperCell) {
        mainViewModel.setupAny(view: cell.mainView)
        additionSetup(cell: cell)
    }

    /// Установка всего, не относящегося к основной модели
    private func additionSetup(cell: WrapperCell) {
        backgroundColor.let { cell.wrapperView.background(color: $0) }
        padding.let { cell.wrapperView.padding($0) }
    }
}

extension CellViewModelByView: UpdatableWithoutReloadingRow, AnyUpdatableWithoutReloadingRow
    where MainViewModel: UpdatableWithoutReloadingRow {

    func update(cell: WrapperCell) {
        mainViewModel.updateAny(cell: cell.mainView)
        additionSetup(cell: cell)
    }
}

// MARK: - Protocols

///
/// Подпишите под это модельку вьюхи,
/// если хотите чтобы естимейт передался целл, сгенерированной на основе ее
///
public protocol EstimatingHeight {
    var estimatedHeight: CGFloat { get }
}

// MARK: - Equatable Cell View Model
extension CellViewModelByView: Equatable, AnyEquatable where MainViewModel: Equatable {}

extension CellViewModelByView: EquatableCellViewModel
    where MainViewModel: EquatableCellViewModel, MainViewModel: AnyEquatable & Equatable {

    var differenceIdentifier: String { mainViewModel.differenceIdentifier }
}

// MARK: - Payload
extension CellViewModelByView: AnyPayloadableCellModel where MainViewModel: AnyPayloadableCellModel {
    var payload: CellModelPayload? {
        get { mainViewModel.payload }
        set { mainViewModel.payload = newValue }
    }
}
