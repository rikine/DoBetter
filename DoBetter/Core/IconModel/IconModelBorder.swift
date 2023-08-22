//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension IconModel {

    struct Border: Equatable {
        /// Define Glyph scaling related to the border.
        public enum GlyphScaling {
            /// A glyph is getting scaled down depending on border width.
            /// So it could fit into the borders without cut edges.
            case considerBorder
            /// Glyph scale is staying exactly the same.
            case `default`
        }

        public let color: UIColor
        public let width: CGFloat
        public let glyphScaling: GlyphScaling

        public init(color: UIColor = .content2, width: CGFloat, glyphScaling: GlyphScaling = .default) {
            self.color = color
            self.width = width
            self.glyphScaling = glyphScaling
        }

        public static let large = Self(width: 8)
        public static let common = Self(width: 4, glyphScaling: .considerBorder)
        public static let mini = Self(width: 2, glyphScaling: .considerBorder)
    }
}
