//
// Created by Никита Шестаков on 22.03.2023.
//

import Foundation
import UIKit

/// Implementation of Horizontal scroll with UICollection
class FlowCollectionView: UICollectionView {

    /// A layout object that organizes items into a collection
    let layout: UICollectionViewFlowLayout

    /// If the delegate does not implement the collectionView(_:layout:sizeForItemAt:) method,
    /// the flow layout uses the value in this property to set the size of each cell.
    /// This results in cells that all have the same size. The default size value is (50.0, 50.0).
    var itemSize: CGSize {
        get { layout.itemSize }
        set { layout.itemSize = newValue }
    }

    /// The default value of this property is .zero. Setting it to any other value,
    /// like automaticSize, causes the collection view to query each cell for
    /// its actual size using the cell’s preferredLayoutAttributesFitting(_:) method.
    var estimatedItemSize: CGSize {
        get { layout.estimatedItemSize }
        set { layout.estimatedItemSize = newValue }
    }

    var isExpandSingleItemEnabled = false

    var scrollBehaviour: FlowCollection.ScrollBehaviour = .plain

    private var targetOffset: CGPoint?

    /// Horizontal dots for paging
    var pageControl: UIPageControl?

    var onItemSelected: ((Int) -> Void)?
    var onReload: ((FlowCollectionView) -> Void)?
    var onCellDequeued: ((UICollectionViewCell, IndexPath, CellViewAnyModel) -> Void)?
    var onHeightChanged: ((CGFloat) -> Void)?

    /// Current state
    private var _selectedIndex: Int = 0
    var selectedIndex: Int {
        get { _selectedIndex }
        set { set(index: newValue, animated: true) }
    }

    var models: [CellViewAnyModel] = [] {
        didSet {
            reloadCollectionView()
            pageControl?.numberOfPages = models.count
        }
    }

    init(collectionViewLayout layout: UICollectionViewFlowLayout = .default) {
        self.layout = layout
        super.init(frame: .zero, collectionViewLayout: layout)
        self.layout.scrollDirection = .horizontal
        delegate = self
        dataSource = self
        clipsToBounds = false
        showsHorizontalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("Are you using storyboard, bitch?!")
    }

    @discardableResult
    func applyDefaultParams() -> Self {
        decelerationRate = .fast
        isExpandSingleItemEnabled = true
        scrollBehaviour = .paged(.singleItem)
        return self
    }

    private func set(index: Int, animated: Bool) {
        awaitReloadData()
        _selectedIndex = index
        setContentOffset(adjustedOffsetForItemAt(index: index), animated: animated)
        pageControl?.currentPage = index
    }

    func reloadItem(at index: Int) {
        reloadItems(at: [indexPath(for: index)])
    }

    func reloadCollectionView() {
        reloadData { [weak self] collectionView in
            self?.layoutIfNeeded()
            self?.onReload?(collectionView)
        }
    }

    /// Retrieves layout information for an item at the specified index path with a corresponding cell
    /// If your cellForItem(at:) is nil, you can still get some layout info here
    /// You can also give the cell a chance to modify the attributes provided by the layout object
    /// through preferredLayoutAttributesFitting(_:) method in your cell class
    private func attributes(for index: Int) -> UICollectionViewLayoutAttributes? {
        layout.layoutAttributesForItem(at: indexPath(for: index))
    }

    /// Turns index to indexPath with single section
    func indexPath(for index: Int) -> IndexPath {
        IndexPath(row: index, section: 0)
    }

    func adjustedOffsetForItemAt(index: Int) -> CGPoint {
        var targetOffset = offsetForItemAt(index: index)

        // Adjust for correct displaying with left padding
        targetOffset.x -= layout.sectionInset.left

        // Doesn't allow to scroll out of contentSize where empty space is shown (ex. offset for last element)
        targetOffset.x = targetOffset.x.clamped(0, contentSize.width - frame.width)

        return targetOffset
    }

    func offsetForItemAt(index: Int) -> CGPoint {
        guard let attributes = attributes(for: index) else { return .zero }
        return attributes.frame.origin
    }
}

extension FlowCollectionView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.item]
        let cell = dequeueReusableCell(withModel: model, for: indexPath)
        onCellDequeued?(cell, indexPath, model)
        return cell
    }
}

protocol ResizableView {
    var cellSize: CGSize { get }
}

extension FlowCollectionView: UICollectionViewDelegate, UIScrollViewDelegate {

    /// Tells the delegate when the user scrolls the content view within the receiver.
    /// The delegate typically implements this method to obtain the change in content offset from scrollView
    /// and draw the affected portion of the content view.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl?.currentPage = itemIndex(for: contentOffset, currentIndex: _selectedIndex)
    }

    /// Called when the user finishes scrolling the content.
    ///
    /// - Parameters:
    ///   - scrollView: The scroll-view object where the user ended the touch.
    ///   - velocity: The velocity of the scroll view (in points) at the moment the touch was released.
    ///   - targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let pagedBehaviour = scrollBehaviour.pagedBehaviour else { return }
        targetOffset = nil

        // Find next index and target offset
        let nextIndex: Int
        switch pagedBehaviour.scrollItemMode {
        case .singleItem: nextIndex = updatedPageIndex(velocity: velocity, currentIndex: _selectedIndex)
        case .manyItems: nextIndex = itemIndex(for: targetContentOffset.pointee, currentIndex: _selectedIndex)
        }
        let targetOffset = adjustedOffsetForItemAt(index: nextIndex)

        // Set scroll offset
        if nextIndex == _selectedIndex {
            self.targetOffset = targetOffset
            targetContentOffset.pointee = scrollView.contentOffset
        } else {
            targetContentOffset.pointee = targetOffset
        }

        // Change selected
        if nextIndex != _selectedIndex {
            _selectedIndex = nextIndex
            if pagedBehaviour.isSelection {
                onItemSelected?(_selectedIndex)
            }
        }
    }

    /// If user scrolls fast enough, then change focused item on 1 to left or right
    /// Otherwise, save the current position on the screen
    private func updatedPageIndex(velocity: CGPoint, currentIndex: Int) -> Int {
        guard abs(velocity.x) > 0.5 else { return currentIndex }
        return (currentIndex + (velocity.x > 0 ? 1 : -1)).clamped(0, models.count - 1)
    }

    private func itemIndex(for targetOffset: CGPoint, currentIndex: Int) -> Int {
        // Adjust offset with section insets, otherwise you will get nil indexPath
        var targetOffset = targetOffset
        targetOffset.x = targetOffset.x.clamped(layout.sectionInset.left, bounds.maxX - layout.sectionInset.right)

        // Get cell for target offset (left top point of collection view when the finger is released from the screen)
        guard var indexPath = indexPathForItem(at: targetOffset),
              let cellAttributes = layout.layoutAttributesForItem(at: indexPath)
        else { return currentIndex }

        // Check if target offset is higher than middle of target element (which means user desire to scroll to another item)
        // If yes, than scroll to next element, otherwise to target element. In practice,
        // needed to scroll correctly to last elements (the maximum targetOffset.x is bounds.maxX - frame.width)
        if targetOffset.x > cellAttributes.frame.midX || bounds.maxX > contentSize.width, indexPath.row < models.count {
            return indexPath.row + 1
        } else {
            return indexPath.row
        }
    }

    /// Tells the delegate when dragging ended in the scroll view.
    ///
    /// - Parameters:
    ///   - scrollView: The scroll-view object that finished scrolling the content view.
    ///   - decelerate: true if the scrolling movement will continue, but decelerate,
    ///                 after a touch-up gesture during a dragging operation.
    ///                 If the value is false, scrolling stops immediately upon touch-up.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollBehaviour.isPaged, !decelerate, let offset = targetOffset else { return }
        scrollView.setContentOffset(offset, animated: true)
    }

    /// The scroll view calls this method as the user’s finger touches up as it is moving during a scrolling operation;
    /// the scroll view will continue to move a short distance afterwards.
    /// The isDecelerating property of UIScrollView controls deceleration.
    /// - Called on finger up as we are moving
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard scrollBehaviour.isPaged, let offset = targetOffset else { return }
        scrollView.setContentOffset(offset, animated: true)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let pagedScrollBehaviour = scrollBehaviour.pagedBehaviour,
           pagedScrollBehaviour.isScrollByTap {
            let isIndexChanged = indexPath.item != selectedIndex
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isUserInteractionEnabled = true
            }
            set(index: indexPath.item, animated: true)
            targetOffset = offsetForItemAt(index: indexPath.item)
            if pagedScrollBehaviour.isSelection, isIndexChanged {
                onItemSelected?(indexPath.row)
            }
            return
        }
        onItemSelected?(indexPath.row)
    }
}

extension FlowCollectionView: UICollectionViewDelegateFlowLayout {

    /// Asks for the size of the specified collection view cell.
    ///
    /// If you do not implement this method, the flow layout uses the values in its itemSize property
    /// to set the size of items instead. Your implementation of this method can return a fixed set of sizes
    /// or dynamically adjust the sizes based on the cell’s content.
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = models[indexPath.item]
        if isExpandSingleItemEnabled, models.count == 1 {
            return CGSize(width: max(itemSize.width, frame.width - layout.sectionInset.horizontalSum),
                          height: itemSize.height)
        } else if let cell = dequeueReusableCell(withModel: model, for: indexPath) as? ResizableView {
            return cell.cellSize
        } else {
            return itemSize
        }
    }
}
