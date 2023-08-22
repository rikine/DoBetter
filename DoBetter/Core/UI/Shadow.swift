//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit
import ViewNodes

struct Shadow {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}

// MARK: There are only 2 types of shadows in project after designers decision. Don't add more.
extension View.Shadow {
    public static let common = View.Shadow(color: .commonShadow, opacity: 0.04, radius: 24, offset: CGSize(width: 0, height: -8))
    public static let card = View.Shadow(color: .cardShadow, opacity: 0.12, radius: 8, offset: CGSize(width: 0, height: 2))
}

// Тени, которые не должны были существовать...
extension View.Shadow {
    public static let button = View.Shadow(color: .commonShadow, opacity: 0.25, radius: 2, offset: .zero)
}

fileprivate extension UIColor {
    static var commonShadow: UIColor { dynamicColor(light: .black, dark: .clear) }
    static var cardShadow: UIColor { dynamicColor(light: .foreground, dark: .clear) }
}
