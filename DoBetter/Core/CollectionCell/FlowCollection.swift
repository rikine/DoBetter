//
// Created by Никита Шестаков on 22.03.2023.
//

import Foundation
import UIKit

/// Models for defining behaviour of FlowCollection
enum FlowCollection {

    typealias Scroll = Table.Scroll

    static let defaultItemWidth = UIScreen.main.bounds.width * 0.85

    enum ScrollBehaviour {
        struct PagedBehaviour {
            enum ScrollItemMode {
                case singleItem, manyItems
            }

            let scrollItemMode: ScrollItemMode
            let isSelection: Bool
            let isScrollByTap: Bool

            init(scrollItemMode: ScrollItemMode, isSelection: Bool = false, isScrollByTap: Bool = false) {
                self.scrollItemMode = scrollItemMode
                self.isSelection = isSelection
                self.isScrollByTap = isScrollByTap
            }

            static let singleItem = PagedBehaviour(scrollItemMode: .singleItem)
            static let manyItems = PagedBehaviour(scrollItemMode: .manyItems)
            static let selectionSingleItem = PagedBehaviour(scrollItemMode: .singleItem, isSelection: true)
        }

        case plain,
             paged(PagedBehaviour)

        var pagedBehaviour: PagedBehaviour? {
            switch self {
            case .paged(let paged): return paged
            case .plain: return nil
            }
        }
        var isPaged: Bool { pagedBehaviour != nil }
    }

    struct Model {
        let collectionModelTypes: [CellViewAnyModel.Type]
        let itemSize: CGSize
        let isExpandSingleItemEnabled: Bool
        let scrollBehaviour: ScrollBehaviour

        init(collectionModelTypes: [CellViewAnyModel.Type],
             itemSize: CGSize = CGSize(width: 140, height: 148),
             isExpandSingleItemEnabled: Bool = false,
             scrollBehaviour: ScrollBehaviour = .plain) {
            self.collectionModelTypes = collectionModelTypes
            self.itemSize = itemSize
            self.isExpandSingleItemEnabled = isExpandSingleItemEnabled
            self.scrollBehaviour = scrollBehaviour
        }
    }
}
