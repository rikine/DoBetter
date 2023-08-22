//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

extension UIColor {
    var highlighted: UIColor { withAlphaComponent(alpha * 0.7) }

    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .light ? light : dark }
    }

    func setBrightness(to percent: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness * percent, alpha: alpha)
    }

    func asUIImage() -> UIImage? {
        UIGraphicsBeginImageContext(.init(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        setFill()
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    var hex: String {
        let (_, r, g, b) = argbComponents
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return NSString(format: "%06x", rgb) as String
    }

    // swiftlint:disable:next large_tuple
    var argbComponents: (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (a, r, g, b)
    }

    var alpha: CGFloat {
        let (a, _, _, _) = argbComponents
        return a
    }

    // swiftlint:disable identifier_name
    convenience init(_ argb: UInt32) {
        let a = (argb > 0xffffff) ? CGFloat((argb & 0xFF000000) >> 24) / 255 : 1
        let r = CGFloat((argb & 0xff0000) >> 16) / 255
        let g = CGFloat((argb & 0x00ff00) >> 8) / 255
        let b = CGFloat((argb & 0x0000ff) >> 0) / 255
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
