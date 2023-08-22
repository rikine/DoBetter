//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import UIKit

enum Table {

    struct SectionViewModel: IndexPathSubscript, Updatable, DifferSectionModelType {

        var header: ViewAnyModel?
        var footer: ViewAnyModel?
        var cells: [CellViewAnyModel]
        var differenceIdentifier: String
        let showHeaderIfSectionIsEmpty: Bool
        let showFooterIfSectionIsEmpty: Bool

        init(header: ViewAnyModel? = nil, footer: ViewAnyModel? = nil,
             cells: [CellViewAnyModel] = [], differenceIdentifier: String? = nil,
             showHeaderIfSectionIsEmpty: Bool = true, showFooterIfSectionIsEmpty: Bool = true) {
            self.header = header
            self.footer = footer
            self.cells = cells
            self.differenceIdentifier = differenceIdentifier ?? String(describing: SectionViewModel.self)
            self.showHeaderIfSectionIsEmpty = showHeaderIfSectionIsEmpty
            self.showFooterIfSectionIsEmpty = showFooterIfSectionIsEmpty
        }

        static let underlyingArray: WritableKeyPath<Self, [CellViewAnyModel]> = \SectionViewModel.cells

        static let empty = SectionViewModel()
    }

    struct Row {
        let indexPath: IndexPath
        let cell: CellViewAnyModel
    }

    enum Data {
        struct ViewModel: DifferUpdatableViewModel, IndexPathSubscript {
            let header: ViewAnyModel?
            let footer: ViewAnyModel?
            var sections: [SectionViewModel]
            let emptyDataPlaceholder: ViewAnyModel?
            let scrollTo: Scroll?
            let showHeaderIfTableIsEmpty: Bool
            let showFooterIfTableIsEmpty: Bool

            static var underlyingArray: WritableKeyPath<Self, [SectionViewModel]> { \.sections }

            init(header: ViewAnyModel? = nil,
                 footer: ViewAnyModel? = nil,
                 sections: [SectionViewModel],
                 emptyDataPlaceholder: ViewAnyModel? = nil,
                 scrollTo: Scroll? = nil,
                 showHeaderIfTableIsEmpty: Bool = false,
                 showFooterIfTableIsEmpty: Bool = false
            ) {
                self.header = header
                self.footer = footer
                self.sections = sections
                self.emptyDataPlaceholder = emptyDataPlaceholder
                self.scrollTo = scrollTo
                self.showHeaderIfTableIsEmpty = showHeaderIfTableIsEmpty
                self.showFooterIfTableIsEmpty = showFooterIfTableIsEmpty
            }

            /// Aliases for cells only
            static func singleSection(with cells: [CellViewAnyModel]) -> Self {
                .init(sections: .single(with: cells))
            }

            static func singleSection(with cells: CellViewAnyModel...) -> Self {
                Self.singleSection(with: cells)
            }
        }

        struct AppendViewModel {
            let lastSectionViewModel: [CellViewAnyModel]?
            let newSectionsViewModels: [SectionViewModel]?

            init(appendToLastSection: [CellViewAnyModel]) {
                lastSectionViewModel = appendToLastSection
                newSectionsViewModels = nil
                _checkIntegrity()
            }

            init(appendToLastSection: [CellViewAnyModel]? = nil, addNewSection: [SectionViewModel]) {
                lastSectionViewModel = appendToLastSection
                newSectionsViewModels = addNewSection
                _checkIntegrity()
            }

            private func _checkIntegrity() {
                assert(lastSectionViewModel != nil || newSectionsViewModels != nil,
                       "At least one of lastSectionViewModel or newSectionViewModel should be nil")
            }
        }
    }

    enum Selection {
        struct Request {
            let indexPath: IndexPath
            let payload: CellModelPayload?
        }
    }

    enum NextPage {
        struct ViewModel {}
    }

    enum TableError {
        struct Response {
            let error: Error
            let dropContent: Bool
        }
    }

    struct PageState {
        let index: Int
        let offset: Int
        let count: Int
        let previousPageTrigger: Int
        let nextPageTrigger: Int

        static let pageSize = 20
        static let windowSize = 50
        static let previousPageTrigger = 5
        static let nextPageTrigger = 35

        static let empty = Self(index: 0, offset: 0, count: 0, previousPageTrigger: 0, nextPageTrigger: 0)
    }

    struct NavBarBottomSeparator {
        enum Behavior {
            case stable
            case hideOnTop
        }

        let height: CGFloat
        let behavior: Behavior
        let color: UIColor

        init(height: CGFloat = 1, behavior: Behavior, color: UIColor = .foreground4) {
            self.height = height
            self.behavior = behavior
            self.color = color
        }

        static let stable = NavBarBottomSeparator(behavior: .stable)
        static let hideOnTop = NavBarBottomSeparator(behavior: .hideOnTop)
    }
}

extension Array where Element == Table.SectionViewModel {
    var allCells: [IndexPath: CellViewAnyModel] {
        enumerated().reduce(into: [IndexPath: CellViewAnyModel]()) { result, section in
            section.element.cells.enumerated().forEach { cell in
                result[IndexPath(row: cell.offset, section: section.offset)] = cell.element
            }
        }
    }

    static func single(with cells: [any CellViewAnyModel]) -> [Table.SectionViewModel] {
        [.init(cells: cells)]
    }

    static func single(with cells: any CellViewAnyModel...) -> [Table.SectionViewModel] {
        single(with: cells)
    }
}

/// Тип объекта, который управляет логикой скролла наследника UIScrollView к определенной позиции
protocol ScrollControllable {
    associatedtype ScrollableToItemView: AnyScrollableToItemView where ScrollableToItemView: UIScrollView & AnyScrollableToItemView
    var scrollableToItemView: ScrollableToItemView? { get }
}

extension ScrollControllable {
    func scroll(to scroll: Table.Scroll) {
        guard let scrollableToItemView else { return }
        switch scroll.position {
        case .point(let point):
            scrollableToItemView.setContentOffset(point, animated: scroll.animated)
        case .pointAccountingInset(var point):
            point.y -= scrollableToItemView.adjustedContentInset.top
            scrollableToItemView.setContentOffset(point, animated: scroll.animated)
        case .row(let indexPath):
            scrollableToItemView.scrollToTopItem(to: scroll, at: indexPath, animated: scroll.animated)
        }
    }
}

extension Table {
    struct Scroll {
        let position: Position
        let animated: Bool

        enum Position {
            case row(IndexPath)
            case point(CGPoint)
            //  scrolls to specified CGPoint, but adjusting `y` component to match contentInset
            case pointAccountingInset(CGPoint)
            static let zero = Position.pointAccountingInset(.zero)

            var withoutAnimation: Scroll { .init(position: self, animated: false) }
            var withAnimation: Scroll { .init(position: self, animated: true) }
        }

        static let zero = Scroll(position: .zero, animated: true)

        var withoutAnimation: Scroll { animated ? .init(position: position, animated: false) : self }
        var withAnimation: Scroll { animated ? self : .init(position: position, animated: true) }
    }
}

/// Тип любого объекта, который имеет навигацию к первому элементу коллекции
protocol AnyScrollableToItemView: AnyObject {
    func scrollToTopItem(to scroll: Table.Scroll, at indexPath: IndexPath, animated: Bool)
}

extension UICollectionView: AnyScrollableToItemView {

    func scrollToTopItem(to scroll: Table.Scroll, at indexPath: IndexPath, animated: Bool) {
        scrollToItem(at: indexPath, at: .top, animated: scroll.animated)
    }
}

extension UITableView: AnyScrollableToItemView {

    func scrollToTopItem(to scroll: Table.Scroll, at indexPath: IndexPath, animated: Bool) {
        scrollToRow(at: indexPath, at: .top, animated: scroll.animated)
    }
}

