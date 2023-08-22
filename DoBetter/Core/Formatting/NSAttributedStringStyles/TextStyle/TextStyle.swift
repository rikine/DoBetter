//
// Created by Maxime Tenth on 2019-07-02.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

public struct TextStyle: Equatable, Updatable {

    static let textDefaultColor = UIColor.foreground

    public var fontSizeValue: CGFloat
    public var fontWeightValue: UIFont.Weight
    public var customFont: CustomFont
    public var lineHeightValue: CGFloat?
    public var lineSpacingValue: CGFloat?
    public var colorValue: UIColor
    public var backgroundColorValue: UIColor?
    public var textAlignmentValue: NSTextAlignment
    public var lineBreakModeValue: NSLineBreakMode
    public var kernValue: CGFloat
    public var baseLineOffsetValue: CGFloat?
    public var linesValue: Int?
    public var labelPaddingValue: UIEdgeInsets?
    public var paragraphSpacingValue: CGFloat

    public var font: UIFont {
        switch customFont {
        case .system:
            return .systemFont(ofSize: fontSizeValue, weight: fontWeightValue)
        case .monospaced:
            return .monospacedDigitSystemFont(ofSize: fontSizeValue, weight: fontWeightValue)
        }
    }

    init(fontSize: CGFloat,
         fontWeight: UIFont.Weight,
         font: CustomFont = .system,
         lineHeight: CGFloat,
         lineSpacing: CGFloat? = nil,
         color: UIColor = TextStyle.textDefaultColor,
         textAlignment: NSTextAlignment = .left,
         lineBreakMode: NSLineBreakMode = .byWordWrapping,
         kern: CGFloat = 0,
         labelPadding: UIEdgeInsets? = nil,
         paragraphSpacing: CGFloat = 0) {
        fontSizeValue = fontSize
        fontWeightValue = fontWeight
        customFont = font
        lineHeightValue = lineHeight
        lineSpacingValue = lineSpacing
        colorValue = color
        backgroundColorValue = nil
        textAlignmentValue = textAlignment
        lineBreakModeValue = lineBreakMode
        kernValue = kern
        labelPaddingValue = labelPadding
        paragraphSpacingValue = paragraphSpacing
    }

    public var attributes: [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = font
        attributes[.foregroundColor] = colorValue
        if let backgroundColor = backgroundColorValue {
            attributes[.backgroundColor] = backgroundColor
        }
        attributes[.kern] = kernValue
        let paragraphStyle = NSMutableParagraphStyle()
        if let lineHeightValue = lineHeightValue {
            attributes[.baselineOffset] = baseLineOffsetValue ?? (lineHeightValue - font.lineHeight) / 4
            paragraphStyle.minimumLineHeight = lineHeightValue
            paragraphStyle.maximumLineHeight = lineHeightValue
        }
        paragraphStyle.alignment = textAlignmentValue
        paragraphStyle.lineBreakMode = lineBreakModeValue
        if let lineSpacing = lineSpacingValue {
            paragraphStyle.lineSpacing = lineSpacing
        }
        paragraphStyle.paragraphSpacing = paragraphSpacingValue
        attributes[.paragraphStyle] = paragraphStyle

        if let lines = linesValue {
            attributes[.numberOfLines] = lines
        }

        if let labelPadding = labelPaddingValue {
            attributes[.labelPadding] = labelPadding
        }

        return attributes
    }
}
