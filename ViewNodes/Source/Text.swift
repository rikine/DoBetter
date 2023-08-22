//
// Created by Maxime Tenth on 10/10/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

open class Text: UIViewWrapper<UILabel> {
    @discardableResult
    public init(_ text: NSAttributedString?) {
        super.init()
        wrapped.attributedText = text
    }

    public override init() {
        super.init()
    }

    public override init(_ label: UILabel) {
        super.init(label)
    }

    // Fix weird gray line on UILabel

    open override func contentSizeThatFits(_ size: CGSize) -> CGSize? {
        super.contentSizeThatFits(size)?.rounded(.up)
    }

    open override var frame: CGRect {
        get { super.frame }
        set {
            super.frame = CGRect(origin: newValue.origin,
                                 size: newValue.size.rounded(.up))
        }
    }

    @discardableResult
    open func text(_ newValue: NSAttributedString?) -> Self {
        if newValue?.length ?? 0 > 0 {
            let attributes = newValue?.attributes(at: 0, effectiveRange: nil)
            if let numberOfLines = attributes?[.numberOfLines] as? Int {
                lines(numberOfLines)
            }
            if let labelHeight = attributes?[.labelHeight] as? CGFloat {
                height(labelHeight + paddingInsets.top + paddingInsets.bottom)
            }
            if let labelPadding = attributes?[.labelPadding] as? UIEdgeInsets {
                padding(labelPadding)
            }
        }
        wrapped.attributedText = newValue
        superview?.setNeedsLayout()
        return self
    }

    @discardableResult
    public func textOrHidden(_ newValue: NSAttributedString?) -> Self {
        text(newValue)
        isHidden = newValue == nil
        superview?.setNeedsLayout()
        return self
    }

    @discardableResult
    public func lines(_ newValue: Int) -> Self {
        wrapped.numberOfLines = newValue
        return self
    }

    @discardableResult
    public func multiline() -> Self { lines(0) }

    @discardableResult
    public func adjustsFontSize(_ scaleFactor: CGFloat) -> Self {
        wrapped.adjustsFontSizeToFitWidth = true
        wrapped.minimumScaleFactor = scaleFactor
        return self
    }

}

extension NSAttributedString.Key {
    public static let numberOfLines = NSAttributedString.Key(rawValue: "maxNumberOfLines")
    public static let labelHeight = NSAttributedString.Key(rawValue: "labelHeight")
    public static let labelPadding = NSAttributedString.Key(rawValue: "labelPadding")
}
