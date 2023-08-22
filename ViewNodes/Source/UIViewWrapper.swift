//
// Created by Maxime Tenth on 10/9/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

/// ViewNode wrapper for UIView classes
/// usage:
/// UIViewWrapper<UIImageView>()
/// UIViewWrapper(UIImageView(image: image))

open class UIViewWrapper<Wrapped: UIView>: View {
    public let wrapped: Wrapped

    @discardableResult
    public init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
        super.init()
        super.addSubview(wrapped)
    }

    @discardableResult
    public override init() {
        self.wrapped = Wrapped()
        super.init()
        super.addSubview(wrapped)
    }

    open override var backgroundColor: UIColor? {
        didSet {
            let color = backgroundColor ?? .clear
            // avoid blending two semi-transparent colors
            wrapped.backgroundColor = color.cgColor.alpha == 1 ? backgroundColor : .clear
        }
    }

    @discardableResult
    open override func content(_ contentClosure: VoidClosure) -> Self {
        for view in subviews {
            if view != wrapped {
                view.removeFromSuperview()
            }
        }
        self.setSubnodes(contentClosure)
        return self
    }
}
