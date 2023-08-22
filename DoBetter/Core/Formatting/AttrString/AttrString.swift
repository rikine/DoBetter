//
// Created by Vasiliy Samarin on 01.09.2021.
// Copyright (c) 2021 vision-invest. All rights reserved.
//

import Foundation
import UIKit

/// Контейнер для хранения текста и его стилистических атрибутов
/// Подробная документация в файле AttrString.swift
public struct AttrString {
    public var string: String = ""
    var attributes: [RangedAttribute] = []
    var attachmentStorage: [AttachmentModel] = []

    public var length: Int { string.count }

    public struct RangedAttribute {
        var attribute: [NSAttributedString.Key: Any]
        var range: NSRange
    }

    public struct AttachmentModel {
        let attachableObject: Attachable
        let position: Int
        let attributes: [NSAttributedString.Key: Any]?

        public init(attachableObject: Attachable, position: Int, attributes: [NSAttributedString.Key: Any]? = nil) {
            self.attachableObject = attachableObject
            self.position = position
            self.attributes = attributes
        }
    }

    public init() {}

    public init(_ string: String, _ attributes: [NSAttributedString.Key: Any]) {
        self.string = string
        self.attributes.append(.init(attribute: attributes, range: _fullRange))
    }

    public init(_ attrString: AttrString, _ attributes: [NSAttributedString.Key: Any]) {
        self = attrString
        self.attributes.append(.init(attribute: attributes, range: _fullRange))
    }

    public mutating func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange) {
        attributes.append(.init(attribute: attrs, range: range))
    }

    ///  Добавляет атрибуты стиля к текущим атрибутам
    @discardableResult
    public func apply(textStyle: TextStyle) -> Self {
        var new = self
        new.attributes.append(.init(attribute: textStyle.attributes, range: _fullRange))
        return new
    }

    @discardableResult
    public func apply(_ style: Style) -> Self {
        var new = self
        new.attributes.append(.init(attribute: style.attributes, range: _fullRange))
        return new
    }

    @discardableResult
    public func interpolated(withTextStyle textStyle: TextStyle) -> NSAttributedString {
        var new = self
        return new.apply(textStyle: textStyle).interpolated()
    }

    private var _fullRange: NSRange { string.fullRange }
}

public extension String {
    var attrString: AttrString { .init(stringLiteral: self) }

    func apply(style: AttrString.Style) -> AttrString {
        attrString.apply(style)
    }

    func apply(textStyle: TextStyle) -> AttrString {
        attrString.apply(textStyle: textStyle)
    }
}

// TODO make this init
// extension AttrString {
//    init(fromAttributedString attributedString: NSAttributedString) {
//        self.string = attributedString.string
//
//        var _lastAttributes = [(NSRange, Any)]()
//        attributedString.enumerateAttributes(
//            in: .init(location: 0, length: attributedString.string.count),
//            using: { attrs, range, _ in
//
//            })
//    }
// }

extension AttrString: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        string = stringLiteral
    }
}

extension AttrString: ExpressibleByStringInterpolation {
    // Allow to use NSAttributedString attributes
    public init(stringInterpolation: StringInterpolation) {
        string = stringInterpolation.string
        attributes = stringInterpolation.attributes
        attachmentStorage = stringInterpolation.attachmentStorage
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        var string: String = ""
        var attributes: [RangedAttribute] = []
        public var attachmentStorage: [AttrString.AttachmentModel] = []

        public var length: Int { string.count }

        public init() {}

        public init(literalCapacity: Int, interpolationCount: Int) {}

        public mutating func appendLiteral(_ literal: String) {
            string += literal
        }

        /// Использование NSAttributedString.Key для добавления стиля к части строки
        ///
        /// var title: AttrString = "этот текст \("красный", attributes: [.foregroundColor : UIColor.red])"
        public mutating func appendInterpolation(_ string: String, attributes: [NSAttributedString.Key: Any]) {
            self.attributes.append(.init(attribute: attributes, range: .init(location: length, length: string.count)))
            self.string += string
        }

        private var _fullRange: NSRange { string.fullRange }
    }
}

extension AttrString: Equatable {
    public static func ==(lhs: AttrString, rhs: AttrString) -> Bool {
        if lhs.interpolated() != rhs.interpolated() { return false }
        return true
    }
}

public extension AttrString {
    /// Финализатор для контейнера.
    ///
    /// var label = UILabel()
    /// var text: AttrString = "этот текст \("синий", AttrString.Style.color(.blue))"
    /// label.attributedText(text.interpolated())
    ///
    /// - Returns: Окончательно сформированная строка со вставленными аттачами и применёнными стилями
    func interpolated() -> NSMutableAttributedString {

        // В первую очередь соберём NSAttributedString
        var interpolatedString = NSMutableAttributedString(string: string)
        attributes.reversed().forEach {
            interpolatedString.addAttributes($0.attribute, range: $0.range)
        }

        // Если есть картинки - аттачим их
        guard attachmentStorage.count > 0 else { return interpolatedString }

        var attachedString = NSMutableAttributedString()
        var interpolatedIndex: Int = 0
        for (index, attachmentModel) in attachmentStorage.enumerated() {
            let length = attachmentModel.position - interpolatedIndex
            attachedString.append(interpolatedString.attributedSubstring(from: .init(location: interpolatedIndex,
                                                                                     length: length)))
            interpolatedIndex += length

            if let attachableObject = attachmentModel.attachableObject as? Attachable {
                var currAttachString = NSAttributedString(
                    attachment: attachableObject.attachment(for: interpolatedString)
                )
                attachmentModel.attributes.let { attrs in
                    currAttachString = currAttachString.addingAttributes(attrs)
                }
                attachedString.append(currAttachString)
            }
        }
        let tail = interpolatedString.attributedSubstring(from: .init(location: interpolatedIndex,
                                                                      length: interpolatedString.length - interpolatedIndex))
        attachedString.append(tail)

        return attachedString
    }
}
