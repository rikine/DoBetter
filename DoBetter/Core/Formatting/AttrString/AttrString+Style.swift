//
// Created by Artem Rylov on 17.02.2022.
// Copyright (c) 2022 vision-invest. All rights reserved.
//

import Foundation
import UIKit

public extension AttrString {
    struct Style {
        var attributes: [NSAttributedString.Key: Any]

        public init(attributes: [NSAttributedString.Key: Any] = [:]) {
            self.attributes = attributes
        }

        public static let empty = Self()

        public static func font(_ size: CGFloat, _ weight: UIFont.Weight) -> Style {
            Style(attributes: [.font: UIFont.systemFont(ofSize: size, weight: weight)])
        }

        public static let headline = Style.font(36, .semibold)
        public static let title = Style.font(24, .bold)
        public static let subtitle = Style.font(20, .semibold)
        public static let body = Style.font(17, .regular)
        public static let line = Style.font(15, .regular)
        public static let label = Style.font(13, .regular)
        public static let detail = Style.font(12, .regular)
        public static let small = Style.font(10, .regular)
        public static let overline = Style.font(10, .bold)

        public func weight(_ weight: UIFont.Weight) -> Style {
            var newStyle = self
            guard let font = newStyle.attributes[.font] as? UIFont else { return self }
            newStyle.attributes[.font] = UIFont.systemFont(ofSize: font.pointSize, weight: weight)
            return newStyle
        }

        public var medium: Style {
            weight(.medium)
        }

        public var bold: Style {
            weight(.bold)
        }

        public var semibold: Style {
            weight(.semibold)
        }

        /// Colors
        public func color(_ color: UIColor?) -> Style {
            var attributes = attributes
            attributes[.foregroundColor] = color
            return .init(attributes: attributes)
        }

        public var white: Style { color(.constantWhite) }

        public var foreground: Style { color(.foreground) }
        public var secondary: Style { color(.foreground2) }
        public var content: Style { color(.content) }
        public var content2: Style { color(.content2) }
        public var accent: Style { color(.accent) }

        public var error: Style { color(.destructive) }
        public var warning: Style { color(.attention) }

        public static func bgColor(_ color: UIColor) -> Style { Style(attributes: [.backgroundColor: color]) }

        public static func link(_ link: String) -> Style { .link(URL(string: link)!) }

        public static func link(_ link: URL) -> Style { Style(attributes: [.link: link]) }

//        static let oblique = Style(attributes: [.obliqueness: 0.1])

        public func lines(_ lines: Int) -> Style {
            var attributes = attributes
            attributes[.numberOfLines] = lines
            return .init(attributes: attributes)
        }

        public var multiline: Style {
            lines(0)
        }

        public static func underline(_ color: UIColor, _ style: NSUnderlineStyle) -> Style {
            Style(attributes: [.underlineColor: color, .underlineStyle: style.rawValue])
        }

        /// Alignment
        public func textAlignment(_ alignment: NSTextAlignment) -> Style {
            var attributes = attributes
            let ps = NSMutableParagraphStyle()
            ps.alignment = alignment
            attributes[.paragraphStyle] = ps
            return .init(attributes: attributes)
        }

        public var left: Style { textAlignment(.left) }
        public var center: Style { textAlignment(.center) }
        public var right: Style { textAlignment(.right) }

        public func strikethrough(_ style: NSUnderlineStyle = NSUnderlineStyle.single) -> Style {
            var attributes = attributes
            attributes[.strikethroughStyle] = style.rawValue as AnyObject
            return .init(attributes: attributes)
        }

        public var strikethrough: Style {
            strikethrough()
        }
    }
}
