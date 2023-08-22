//
//  TextStyle+Constants.swift
//  VisionInvestUI
//
//  Created by Вадим Серегин on 24.10.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import Foundation
import UIKit

public extension TextStyle {
    static let headline
        = TextStyle(fontSize: 36, fontWeight: .semibold, lineHeight: 44, color: Self.textDefaultColor, kern: 0.35)
    static let title
        = TextStyle(fontSize: 24, fontWeight: .bold, lineHeight: 32, color: Self.textDefaultColor)
    static let subtitle
        = TextStyle(fontSize: 20, fontWeight: .semibold, lineHeight: 28, color: Self.textDefaultColor)
    static let body
        = TextStyle(fontSize: 17, fontWeight: .regular, lineHeight: 24, color: Self.textDefaultColor)
    static let line
        = TextStyle(fontSize: 15, fontWeight: .regular, lineHeight: 20, color: Self.textDefaultColor)
    static let label
        = TextStyle(fontSize: 13, fontWeight: .regular, lineHeight: 16, color: Self.textDefaultColor)
    static let detail
        = TextStyle(fontSize: 12, fontWeight: .regular, lineHeight: 16, color: Self.textDefaultColor)
    static let small
        = TextStyle(fontSize: 10, fontWeight: .regular, lineHeight: 16, color: Self.textDefaultColor)
    static let overline
        = TextStyle(fontSize: 10, fontWeight: .bold, lineHeight: 16, color: Self.textDefaultColor, kern: 1.25)
}
