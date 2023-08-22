//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

/// Объекты, которые могут преобразовываться в NSTextAttachment,
/// для вставки в NSAttributedString
///
/// Например:
/// - `IconModel` для вставки изображений
/// - `CGFloat` для вставки отступов в стоку
public protocol Attachable {
    func attachment(for nsAttributedString: NSAttributedString) -> NSTextAttachment
}

extension CGFloat: Attachable {
    public func attachment(for nsAttributedString: NSAttributedString) -> NSTextAttachment {
        let attach = NSTextAttachment()
        attach.bounds = CGRect(x: 0, y: 0, width: self, height: 0)
        return attach
    }
}

extension IconModel: Attachable {
    public func attachment(for nsAttributedString: NSAttributedString) -> NSTextAttachment {
        let capHeight: CGFloat?
        /// Аппа падает, если вызвать .font или .capHeight, при длине == 0
        /// Просто без объяснений (:
        if nsAttributedString.length > 0 {
            let font = nsAttributedString.font(at: nsAttributedString.fullRange)
                ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
            capHeight = font.capHeight
        } else {
            capHeight = nil
        }

        return IconAttachment(
            iconModel: self,
            capHeight: capHeight
        )
    }
}
