//
//  TextStyle+Updatable.swift
//  VisionInvestUI
//
//  Created by Вадим Серегин on 24.10.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import Foundation
import UIKit

public extension TextStyle {

    /// 400
    var regular: TextStyle {
        fontWeight(.regular)
    }

    /// 500
    var medium: TextStyle {
        fontWeight(.medium)
    }

    /// 600
    var semibold: TextStyle {
        fontWeight(.semibold)
    }

    /// 700
    var bold: TextStyle {
        fontWeight(.bold)
    }

    var secondary: TextStyle {
        color(.foreground2)
    }

    var content: TextStyle {
        color(.content)
    }

    var content2: TextStyle {
        color(.content2)
    }

    var error: TextStyle {
        color(.destructive)
    }

    var warning: TextStyle {
        color(.attention)
    }

    var qaFeature: TextStyle {
        color(.qaFeature)
    }

    var left: TextStyle {
        textAlignment(.left)
    }

    var center: TextStyle {
        textAlignment(.center)
    }

    var right: TextStyle {
        textAlignment(.right)
    }

    var truncatingTail: TextStyle {
        lineBreakMode(.byTruncatingTail)
    }

    func lines(_ newValue: Int?) -> TextStyle {
        var style = self
        style.linesValue = newValue
        return style
    }

    var multiline: TextStyle { lines(0) }

    var defaultKern: TextStyle { kern(0) }

    var monospaced: TextStyle {
        var style = self
        style.customFont = .monospaced
        return style
    }

    func fontSize(_ newValue: CGFloat) -> TextStyle {
        var style = self
        style.fontSizeValue = newValue
        return style
    }

    func fontWeight(_ newValue: UIFont.Weight) -> TextStyle {
        var style = self
        style.fontWeightValue = newValue
        return style
    }

    func lineHeight(_ newValue: CGFloat?) -> TextStyle {
        var style = self
        style.lineHeightValue = newValue
        return style
    }

    func lineSpacing(_ newValue: CGFloat?) -> TextStyle {
        var style = self
        style.lineSpacingValue = newValue
        return style
    }

    func color(_ newValue: UIColor) -> TextStyle {
        var style = self
        style.colorValue = newValue
        return style
    }

    func backgroundColor(_ newValue: UIColor?) -> TextStyle {
        var style = self
        style.backgroundColorValue = newValue
        return style
    }

    func textAlignment(_ newValue: NSTextAlignment) -> TextStyle {
        var style = self
        style.textAlignmentValue = newValue
        return style
    }

    func lineBreakMode(_ newValue: NSLineBreakMode) -> TextStyle {
        var style = self
        style.lineBreakModeValue = newValue
        return style
    }

    func kern(_ newValue: CGFloat) -> TextStyle {
        var style = self
        style.kernValue = newValue
        return style
    }

    func baseLineOffset(_ newValue: CGFloat?) -> TextStyle {
        var style = self
        style.baseLineOffsetValue = newValue
        return style
    }

    func labelPadding(_ newValue: UIEdgeInsets?) -> TextStyle {
        var style = self
        style.labelPaddingValue = newValue
        return style
    }

    func paragraphSpacing(_ newValue: CGFloat) -> TextStyle {
        var style = self
        style.paragraphSpacingValue = newValue
        return style
    }
}

public extension String {
    func style(_ style: TextStyle) -> NSAttributedString {
         NSMutableAttributedString(string: self, attributes: style.attributes).interpolateImages()
    }
}

public extension NSAttributedString {
    func style(_ style: TextStyle) -> NSAttributedString {
        let resultString = NSMutableAttributedString(attributedString: self).addingAttributes(style.attributes).interpolateImages()
        if resultString.length > 0 {
            resultString.iterateIcons { attachment in
                if let capHeight = (style.attributes[.font] as? UIFont)?.capHeight {
                    attachment.bounds.origin.y = (capHeight - attachment.bounds.size.height) / 2
                }
            }
        }

        return resultString
    }

    func iterateIcons(usingBlock block: @escaping (IconAttachment) -> Void) {
        let range = NSRange(location: 0, length: length)
        enumerateAttribute(.attachment,
                           in: range) { any, _, _ in
            if let attachment = any as? IconAttachment {
                block(attachment)
            }
        }
    }
}

public extension Optional where Wrapped == String {
    func style(_ style: TextStyle) -> NSAttributedString {
        switch self {
        case .some(let value):
            return value.style(style)
        case .none:
            return "-".style(style)
        }
    }
}
