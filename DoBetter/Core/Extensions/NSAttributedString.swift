//
//  NSAttributedString.swift
//  VisionInvestUtils
//
//  Created by Вадим Серегин on 22.10.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import Foundation

public extension NSAttributedString {

    static var lineBreak: NSAttributedString { NSAttributedString(string: "\n") }

    var fullRange: NSRange { .init(location: 0, length: length) }

    func trimmingCharacters(in set: CharacterSet) -> NSAttributedString {
        let invertedSet = set.inverted
        let rangeFromStart = string.rangeOfCharacter(from: invertedSet)
        let rangeFromEnd = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        if let startLocation = rangeFromStart?.upperBound, let endLocation = rangeFromEnd?.lowerBound {
            let location = string.distance(from: string.startIndex, to: startLocation) - 1
            let length = string.distance(from: startLocation, to: endLocation) + 2
            let newRange = NSRange(location: location, length: length)
            return self.attributedSubstring(from: newRange)
        } else {
            return NSAttributedString()
        }
    }

    func nsRange(of substring: String) -> NSRange? {
        string.nsRange(of: substring)
    }

    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        var result: NSMutableAttributedString! = left.mutableCopy() as? NSMutableAttributedString
        var right: NSMutableAttributedString! = right.mutableCopy() as? NSMutableAttributedString

        // used to align IconAttachment
        result = result.alignAttachment(to: right)
        right = right.alignAttachment(to: result)

        result.append(right)
        return result
    }
}

import UIKit

public extension NSMutableAttributedString {

    func alignAttachment(to string: NSAttributedString) -> NSMutableAttributedString? {
        guard length > 0, string.length > 0 else { return self }

        let attachmentAttributes = attributes(at: 0, effectiveRange: nil)
        if let attachment = attachmentAttributes[.attachment] as? NSTextAttachment,
           let image = attachment.image,
           !attachmentAttributes.contains(where: \.key, isNotIn: [.attachment]) {
            let range = NSRange(location: 0, length: string.length)
            var newAttributes = string.attributes(at: 0, effectiveRange: nil)
            let font = string.font(at: range)
            font.let { newAttributes[.font] = $0 }
            let capHeight = font?.capHeight
            let y: CGFloat
            if let capHeight = capHeight {
                y = (capHeight - image.size.height) / 2
            } else {
                y = 0
            }
            attachment.bounds = CGRect(x: 0,
                                       y: y,
                                       width: image.size.width,
                                       height: image.size.height)
            newAttributes[.attachment] = attachment

            let rightLineHeight = string.font(at: range)?.lineHeight ?? 0
            let paragraphStyle = currentMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = max(image.size.height, rightLineHeight)
            paragraphStyle.maximumLineHeight = max(image.size.height, rightLineHeight)
            newAttributes[.paragraphStyle] = paragraphStyle

            return addingAttributes(newAttributes) as? NSMutableAttributedString
        }

        return self
    }
}
