//
// Created by Artem Rylov on 17.02.2022.
// Copyright (c) 2022 vision-invest. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Strings
public extension AttrString.StringInterpolation {
    /// Возвращает все атрибуты из переданных стилей
    static private func _attributes(byStyles styles: [AttrString.Style]) -> [NSAttributedString.Key: Any] {
        styles.reduce(into: [:]) { $0 += $1.attributes }
    }

    mutating func appendInterpolation(_ attrString: AttrString, _ style: TextStyle) {
        self += AttrString(attrString, style.attributes)
    }

    /// Применение старых стилей TextStyle
    ///
    /// var textWithOldStyle: AttrString = "этот текст \("огромный", .headline)"
    ///
    /// - Parameters:
    ///   - string: Строка к которой применяется стиль
    ///   - style: Стиль
    mutating func appendInterpolation(_ string: String, _ style: TextStyle) {
        self += AttrString(string, style.attributes)
    }

    /// Применение старых стилей TextStyle для вложенных строк
    ///
    /// var textWithOldStyle2: AttrString = "этот \(wrap: "а этот поменьше", .line)текст \("огромный", .headline)"
    mutating func appendInterpolation(wrap string: AttrString, _ style: TextStyle) {
        self += AttrString(string, style.attributes)
    }

    /// Применение нескольких собственных стилей AttrString.Style
    ///
    /// var title1: AttrString = "этот текст \("синий", AttrString.Style.color(.blue))"
    /// var title2: AttrString = "а этот текст \("жёлтый и подчёркнут зеленью", .color(.yellow), .underline(.green, .byWord))"
    mutating func appendInterpolation(_ string: String, _ style: AttrString.Style...) {
        self += AttrString(string, Self._attributes(byStyles: style))
    }

    /// То же самое, но для вложенных строк
    ///
    /// var title2_1 = AttrString("Съешь же ещё этих \(wrap: "мягких", .color(.red)) булок, да выпей чаю")
    mutating func appendInterpolation(wrap string: AttrString, _ style: AttrString.Style...) {
        self += AttrString(string, Self._attributes(byStyles: style))
    }

    /// Стиль можно воткнуть в любое место строки, и он применится на всю длину
    ///
    /// var title2_2 = AttrString("Съешь же ещё этих \(wrap: "мягких", .color(.red)) булок, да выпей чаю\(.color(.green))")
    mutating func appendInterpolation(style: AttrString.Style...) {
        attributes.append(AttrString.RangedAttribute(attribute: Self._attributes(byStyles: style),
                                                     range: string.fullRange))
    }
}

// MARK: - Spaces
public extension AttrString.StringInterpolation {
    private mutating func _appendSpace(_ width: CGFloat) {
        attachmentStorage.append(.init(attachableObject: width, position: length))
    }

    /// Механизм для вставки между буквами и/или аттачами пустых промежутков с заданным размером
    ///
    /// var title4: AttrString = "зуб1 \(space: 20) зуб2)"
    ///
    /// - Parameter space: ширина в pt
    mutating func appendInterpolation(space: CGFloat) {
        _appendSpace(space)
    }

    /// Механизм для вставки картинок и опциональных отступов по бокам
    ///
    /// var textWithOldStyle: AttrString = "глаз \(icon: IconModel.circleArrowUp.padding(.horizontal(8)) глаз"
    ///
    /// - Parameters:
    ///   - icon: картинка IconModel
    mutating func appendInterpolation(icon: IconModel?) {
        guard let icon = icon else { return }
        attachmentStorage.append(.init(attachableObject: icon, position: length))
    }
}

// MARK: - Unusual
public extension AttrString.StringInterpolation {
    /// Применение доступного атрибута при выполнении условия
    ///
    /// var text: AttrString = "этот текст \(if: isBlue(), .color(.blue))"
    ///
    /// - Parameters:
    ///   - condition: Условие, при выполнении которого применится атрибут
    ///   - literal: применяемый атрибут
    mutating func appendInterpolation(if condition: @autoclosure () -> Bool, _ literal: StringLiteralType) {
        guard condition() else { return }
        appendLiteral(literal)
    }
}
