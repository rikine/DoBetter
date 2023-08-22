//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit
import SwiftGifOrigin

extension UIImage {
    struct ActivityIndication {
        static let defaultSize: CGSize = .square(32)
        static let medium: CGSize = .square(24)

        private static let spinnerImageName = "spinner-white"
        static let small: CGSize = .square(16)
        static let whiteSpiner = UIImage.gif(name: Self.spinnerImageName)!
        static let whiteSpinerSmall = Glyph(image: UIImage.gif(name: Self.spinnerImageName)!)!
                .changeGlyphSize(size: Self.small).image
    }
}
