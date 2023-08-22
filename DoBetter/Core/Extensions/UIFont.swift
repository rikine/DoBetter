//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension UIFont {
    /*
     https://gist.github.com/joncardasis/4d40e9782ca6b1f3d2ef8abd0290794c
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    static func bestFittingFontSize(for text: String,
                                    in bounds: CGRect,
                                    fontDescriptor: UIFontDescriptor,
                                    additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]

        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension

        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont

            let currentFrame = text.boundingRect(with: infiniteBounds,
                                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                 attributes: attributes,
                                                 context: nil)

            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }
}
