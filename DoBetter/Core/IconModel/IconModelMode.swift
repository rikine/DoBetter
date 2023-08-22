//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

public extension IconModel {

    struct IconModelMode {

        public enum SizeMode {
            case small, medium, regular, large
        }

        public enum ShapeMode {
            case circle, squircle
        }

        public let sizeMode: SizeMode
        public let shapeMode: ShapeMode?

        public var shape: Shape? {
            guard let shapeMode = shapeMode else { return nil }
            switch (sizeMode, shapeMode) {
            case (.small, .circle): return .smallCircle
            case (.small, .squircle): return .smallSquircle
            case (.medium, .circle): return .mediumCircle
            case (.medium, .squircle): return .mediumSquircle
            case (.regular, .circle): return .circle
            case (.regular, .squircle): return .squircle
            case (.large, .circle): return .largeCircle
            case (.large, .squircle): return .largeSquircle
            }
        }

        public func scale(glyph: Glyph) -> Glyph {
            switch sizeMode {
            case .small: return glyph.small
            case .regular: return glyph.regular
            case .medium: return glyph.medium
            case .large: return glyph.large
            }
        }

        public static let smallCircle = IconModelMode(sizeMode: .small, shapeMode: .circle)
        public static let smallSquircle = IconModelMode(sizeMode: .small, shapeMode: .squircle)
        public static let regularCircle = IconModelMode(sizeMode: .regular, shapeMode: .circle)
        public static let regularSquircle = IconModelMode(sizeMode: .regular, shapeMode: .squircle)
        public static let mediumCircle = IconModelMode(sizeMode: .medium, shapeMode: .circle)
        public static let mediumSquircle = IconModelMode(sizeMode: .medium, shapeMode: .squircle)
        public static let largeCircle = IconModelMode(sizeMode: .large, shapeMode: .circle)
        public static let largeSquircle = IconModelMode(sizeMode: .large, shapeMode: .squircle)
    }
}
