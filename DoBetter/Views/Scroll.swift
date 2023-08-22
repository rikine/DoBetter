//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import UIKit
import ViewNodes

open class Scroll: UIViewWrapper<UIScrollView> {
    let axis: Axis

    public init(axis: Axis, scroll: UIScrollView? = nil) {
        self.axis = axis
        if let scroll = scroll {
            super.init(scroll)
        } else {
            super.init()
        }
        wrapped.showsHorizontalScrollIndicator = false
        wrapped.showsVerticalScrollIndicator = false
    }

    open override func addSubnode(_ node: NodeType) {
        subnodes.append(node)
        if let view = node as? View {
            wrapped.addSubview(view)
        }
    }

    open override func contentSizeThatFits(_ size: CGSize) -> CGSize? {
        let sizeToFit = _sizeToFit(size)
        guard let contentSize = wrapped.subviews.first?.sizeThatFits(sizeToFit) else { return nil }
        switch axis {
        case .horizontal:
            return CGSize(width: size.width,
                          height: contentSize.height)
        case .vertical:
            return CGSize(width: contentSize.width,
                          height: size.height)

        }
    }

    open override func nodeLayoutSubviews() {
        super.nodeLayoutSubviews()
        let sizeToFit = _sizeToFit(bounds.size)
        guard var contentSize = wrapped.subviews.first?.sizeThatFits(sizeToFit) else { return }
        switch axis {
        case .horizontal:
            contentSize.height = sizeToFit.height
        case .vertical:
            contentSize.width = sizeToFit.width
        }
        wrapped.subviews.first?.frame.size = contentSize
        wrapped.contentSize = contentSize
    }

    private func _sizeToFit(_ size: CGSize) -> CGSize {
        let sizeToFit: CGSize
        switch axis {
        case .horizontal:
            sizeToFit = CGSize(width: .greatestFiniteMagnitude,
                               height: size.height)
        case .vertical:
            sizeToFit = CGSize(width: size.width,
                               height: .greatestFiniteMagnitude)

        }
        return sizeToFit
    }

    @discardableResult
    public func contentInset(_ inset: UIEdgeInsets) -> Self {
        wrapped.contentInset = inset
        return self
    }

    @discardableResult
    public func contentInsetAdjustmentBehavior(_ newValue: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        wrapped.contentInsetAdjustmentBehavior = newValue
        return self
    }
}

open class HScroll: Scroll {
    @discardableResult
    public init(scroll: UIScrollView? = nil) { super.init(axis: .horizontal, scroll: scroll) }
}

open class VScroll: Scroll {
    @discardableResult
    public init(scroll: UIScrollView? = nil) { super.init(axis: .vertical, scroll: scroll) }
}

// TODO: Refactor scroll, remove this shit
open class VScrollCompact: VScroll {

    private func _sizeToFit(_ size: CGSize) -> CGSize {
        CGSize(width: size.width,
               height: .greatestFiniteMagnitude)
    }

    open override func contentSizeThatFits(_ size: CGSize) -> CGSize? {
        let sizeToFit = _sizeToFit(size)
        guard let contentSize = wrapped.subviews.first?.sizeThatFits(sizeToFit) else { return nil }
        return contentSize
    }
}

extension Scroll {
    enum RectToVisible {
        enum Mode {
            // Scroll so rect is just visible (nearest edges). nothing if rect completely visible
            case `default`
            // Same as `default` but you set animation ability
            case animated(Bool)
        }
    }
}
