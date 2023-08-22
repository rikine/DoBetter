//
//  NSAttributedString+Attributes.swift
//  VisionInvest
//
//  Created by Вадим Серегин on 23.07.2021.
//  Copyright © 2021 vision-invest. All rights reserved.
//

import UIKit

public extension NSAttributedString {

    func textAttributes(at range: NSRange? = nil) -> [NSAttributedString.Key : Any] {
        let range = range ?? defaultRange
        return attributes(at: range.location, longestEffectiveRange: nil, in: range)
    }

    func font(at range: NSRange? = nil) -> UIFont? {
        value(for: .font, at: range) as? UIFont
    }

    func foregroundColor(at range: NSRange? = nil) -> UIColor? {
        value(for: .foregroundColor, at: range) as? UIColor
    }

    func baseLineOffset(at range: NSRange? = nil) -> CGFloat? {
        value(for: .baselineOffset, at: range) as? CGFloat
    }

    func lineHeight(at range: NSRange? = nil) -> CGFloat? {
        guard length > 0 else { return 0 }

        let range = range ?? defaultRange
        let attrs = attributes(at: range.location, effectiveRange: nil)
        if let font = (attrs.first { $0.key == .font }?.value as? UIFont) {
            return font.lineHeight
        } else {
            return nil
        }
    }

    // MARK: Private

    public var defaultRange: NSRange {
        NSRange(location: 0, length: length)
    }

    private func value(for key: NSAttributedString.Key, at range: NSRange? = nil) -> Any? {
        let range = range ?? defaultRange
        return attribute(key, at: range.location, longestEffectiveRange: nil, in: range)
    }
}

// MARK: - Adding attributes

public extension NSAttributedString {
    func lineBreakMode(_ mode: NSLineBreakMode) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = mode
        return addingAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }

    var truncatingTail: NSAttributedString {
        lineBreakMode(.byTruncatingTail)
    }

    var truncatingMiddle: NSAttributedString {
        lineBreakMode(.byTruncatingMiddle)
    }

    func addingAttributes(_ attributes: [NSAttributedString.Key: Any], for range: NSRange? = nil) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.addAttributes(attributes, range: range ?? NSRange(location: 0, length: length))
        return mutable
    }

    func settingAlignment(_ alignment: NSTextAlignment, range: NSRange? = nil) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.setAlignment(alignment, range: range ?? .init(location: 0, length: length))
        return mutable
    }

    func settingFontWeight(_ weight: UIFont.Weight) -> NSAttributedString {
        guard let fontSize = font()?.pointSize else { return self }
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.setFontWeight(weight, ofSize: fontSize)
        return mutable
    }

    func settingFontWeight(_ rawValue: CGFloat) -> NSAttributedString {
        settingFontWeight(UIFont.Weight(rawValue))
    }
}

public extension NSMutableAttributedString {

    func currentMutableParagraphStyle(range: NSRange? = nil) -> NSMutableParagraphStyle {
        let range = range ?? NSRange(location: 0, length: length)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        let currentParagraphStyle = attribute(.paragraphStyle,
                                              at: range.location,
                                              effectiveRange: nil) as? NSParagraphStyle
        currentParagraphStyle.map(mutableParagraphStyle.setParagraphStyle(_:))
        return mutableParagraphStyle
    }

    func setAlignment(_ alignment: NSTextAlignment, range: NSRange) {
        let newParagraphStyle = currentMutableParagraphStyle()
        newParagraphStyle.alignment = alignment
        addAttributes([.paragraphStyle: newParagraphStyle], range: range)
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        setAlignment(alignment, range: NSRange(location: 0, length: length))
    }

    func setFontWeight(_ weight: UIFont.Weight, ofSize: CGFloat) {
        let font = UIFont.systemFont(ofSize: ofSize, weight: weight)
        addAttributes([.font: font], range: NSRange(location: 0, length: length))
    }
}
