//
// Created by Никита Шестаков on 22.03.2023.
//

import Foundation
import UIKit

class FlowCollectionCell: UITableViewCell {

    static let defaultPaddingBottom: CGFloat = 4

    let collectionView: FlowCollectionView
    class var layout: UICollectionViewFlowLayout { .default }
    var paddingTop: CGFloat = 4 {
        didSet {
            topConstraint.constant = -paddingTop
        }
    }
    /// Bottom padding between |collectionView|---|contentView|
    ///
    /// Have to be configured if page control indicator needed. More in `PagedFlowCollectionCell`
    var paddingBottom: CGFloat = defaultPaddingBottom {
        didSet {
            bottomConstraint.constant = paddingBottom
        }
    }
    private lazy var topConstraint = contentView.topAnchor
            .constraint(equalTo: collectionView.topAnchor, constant: -paddingTop)
    private lazy var bottomConstraint = contentView.bottomAnchor
            .constraint(equalTo: collectionView.bottomAnchor, constant: paddingBottom)

    override init(style: CellStyle, reuseIdentifier: String?) {
        collectionView = FlowCollectionView(collectionViewLayout: Self.layout)
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.al()
        collectionView.contentInsetAdjustmentBehavior = .never
        contentView.addSubview(collectionView)
        contentView.addConstraints([topConstraint,
                                    bottomConstraint,
                                    contentView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                                    contentView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)])
    }

    required init?(coder: NSCoder) {
        fatalError("Are you using storyboard, bitch?!")
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        let collectionHeight = collectionView.itemSize.height
        let height = collectionHeight + paddingTop + paddingBottom
        return CGSize(width: targetSize.width, height: height)
    }
}

struct FlowCollectionCellModel<T: CellViewAnyModel & AnyEquatable>: EquatableCellViewModel, Equatable {
    var itemType: T.Type
    var items: [T]
    let itemSize: CGSize
    let scrollBehaviour: FlowCollection.ScrollBehaviour
    let isExpandSingleItemEnabled: Bool
    let onItemSelected: ((Int) -> Void)?
    let backgroundColor: UIColor?
    let onCellDequeued: ((UICollectionViewCell, IndexPath, CellViewAnyModel) -> Void)?
    let paddingBottom: CGFloat

    /// Set this property to keep selected item when cells reused
    var preselectedIndex: Int?
    /// Set this property to always update preselected item to correct position
    /// Got case when after `pull to refresh`, happens 2 full loads and preselectedItem works not correctly
    var preselectedIndexAlwaysUpdate: Bool

    init(items: [T], itemSize: CGSize, scrollBehaviour: FlowCollection.ScrollBehaviour, isExpandSingleItemEnabled: Bool,
         preselectedItem: Int? = nil, preselectedIndexAlwaysUpdate: Bool = false,
         onItemSelected: ((Int) -> Void)? = nil, backgroundColor: UIColor? = nil,
         onCellDequeued: ((UICollectionViewCell, IndexPath, CellViewAnyModel) -> Void)? = nil,
         paddingBottom: CGFloat = FlowCollectionCell.defaultPaddingBottom) {
        self.itemType = T.self
        self.items = items
        self.itemSize = itemSize
        self.scrollBehaviour = scrollBehaviour
        self.isExpandSingleItemEnabled = isExpandSingleItemEnabled
        self.preselectedIndex = preselectedItem
        self.preselectedIndexAlwaysUpdate = preselectedIndexAlwaysUpdate
        self.onItemSelected = onItemSelected
        self.backgroundColor = backgroundColor
        self.onCellDequeued = onCellDequeued
        self.paddingBottom = paddingBottom
    }

    static func ==(lhs: FlowCollectionCellModel, rhs: FlowCollectionCellModel) -> Bool {
        lhs.itemType == rhs.itemType && lhs.items.isEqual(to: rhs.items)
    }
}

extension FlowCollectionCellModel: CellViewModel {
    func setup(cell: FlowCollectionCell) {
        cell.selectionStyle = .none
        cell.collectionView.register(models: itemType)
        cell.collectionView.itemSize = itemSize
        cell.collectionView.scrollBehaviour = scrollBehaviour
        cell.collectionView.onItemSelected = onItemSelected
        cell.collectionView.models = items
        cell.collectionView.isExpandSingleItemEnabled = isExpandSingleItemEnabled
        cell.collectionView.onCellDequeued = onCellDequeued
        backgroundColor.map {
            cell.backgroundColor = $0
            cell.collectionView.backgroundColor = $0
        }
        preselectedIndex.map {
            if cell.collectionView.selectedIndex != $0 || preselectedIndexAlwaysUpdate {
                cell.collectionView.selectedIndex = $0
            }
        }
        cell.paddingBottom = paddingBottom
    }
}

extension UICollectionViewFlowLayout {
    static var defaultSectionInset: UIEdgeInsets = .horizontal(8)

    static var `default`: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = Self.defaultSectionInset
        return layout
    }
}
