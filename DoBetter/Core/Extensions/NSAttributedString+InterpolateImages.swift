//
// Created by Maxime Tenth on 9/10/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

// swiftlint:disable:next force_try
private let _imageRegex = try! NSRegularExpression(pattern: #"#img\(([^\)]*)\)"#)

public extension NSAttributedString {
    func interpolateImages() -> NSAttributedString {
        let string = self.string
        let matches = _imageRegex.matches(in: string,
                                          range: NSRange(string.startIndex..., in: string))
                .filter {
                    $0.numberOfRanges == 2
                }.reversed()
        guard matches.count > 0 else { return self }
        let attributedString: NSMutableAttributedString! = mutableCopy() as? NSMutableAttributedString
        for match in matches {
            let imageNameRange: Range! = Range(match.range(at: 1), in: string)
            let imageName = String(string[imageNameRange])
            let imageAttachment = NSTextAttachment()
            if let image = UIImage(named: imageName) {

                imageAttachment.image = image
                if let font = font(at: match.range) {
                    let offset: CGFloat = baseLineOffset(at: match.range) ?? 0
                    imageAttachment.bounds = CGRect(origin: CGPoint(x: 0,
                                                                    y: offset + (font.capHeight - image.size.height) / 2),
                                                    size: image.size)
                }
            }

            let paragraphStyle = NSMutableParagraphStyle()
            let attrs = attributes(at: match.range.location, effectiveRange: nil)
            if let originParagraphStyle = (attrs.first { $0.key == .paragraphStyle }?.value as? NSParagraphStyle ) {
                paragraphStyle.alignment = originParagraphStyle.alignment
            }
            let imageString = NSAttributedString(attachment: imageAttachment).addingAttributes([.paragraphStyle: paragraphStyle])
            attributedString.replaceCharacters(in: match.range, with: imageString)
        }
        return attributedString
    }

    func font(at range: NSRange) -> UIFont? {
        return attributes(at: range.location, effectiveRange: nil).first { $0.key == .font }?.value as? UIFont
    }

    private func baseLineOffset(at range: NSRange) -> CGFloat? {
        attributes(at: range.location, effectiveRange: nil).first { $0.key == .baselineOffset }?.value as? CGFloat
    }

    func paragraphStyle(at range: NSRange) -> NSParagraphStyle? {
        let attrs = attributes(at: range.location, effectiveRange: nil)
        return attrs.first { $0.key == .paragraphStyle }?.value as? NSParagraphStyle
    }
}

public extension String {
    var img: String { "#img(\(self))" }
}
