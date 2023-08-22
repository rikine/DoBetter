//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension UIColor {
    static var accent: UIColor = dynamicColor(light: .mintBase, dark: .mintBaseNight)
    static var background: UIColor = dynamicColor(light: .fixed10, dark: .constantBlack)
    static var background2: UIColor = dynamicColor(light: .constantWhite, dark: .constantBlack)
    static var elevated: UIColor = dynamicColor(light: .constantWhite, dark: .fixed110)
    static var smoke: UIColor = dynamicColor(light: .whiteSmoke, dark: .blackSmoke)

    static var content: UIColor = dynamicColor(light: .constantWhite, dark: .midnight)
    static var content2: UIColor = dynamicColor(light: .fixed10, dark: .midnight)

    static var foreground: UIColor = dynamicColor(light: .fixed110, dark: .constantWhite)
    static var foreground2: UIColor = dynamicColor(light: .fixed60, dark: .fixed60)
    static var foreground3: UIColor = dynamicColor(light: .fixed40, dark: .fixed80)
    static var foreground4: UIColor = dynamicColor(light: .fixed20, dark: .fixedBase)
    static var foregroundSecondary: UIColor = dynamicColor(light: .constantWhite, dark: .fixed110)

    static var constructive: UIColor = .successBase
    static var halfConstructive: UIColor = dynamicColor(light: .clrPictachioBase, dark: .clrPictachio110)
    static var constructiveBackground: UIColor = dynamicColor(light: .success10, dark: .successUltradark)
    static var constructiveBackground2: UIColor = .dynamicColor(light: .success20, dark: .successDark)

    static var destructive: UIColor = .criticalBase
    static var halfDestructive: UIColor = dynamicColor(light: .halfDestructiveLight, dark: .halfDestructiveDark)
    static var destructiveBackground: UIColor = dynamicColor(light: .critical10, dark: .criticalUltradark)
    static var destructiveBackground2: UIColor = .dynamicColor(light: .critical20, dark: .criticalDark)

    static var attention: UIColor = .alertBase
    static var attentionBackground: UIColor = dynamicColor(light: .alert10, dark: .alertUltradark)
    static var attentionBackground2: UIColor = dynamicColor(light: .alert20, dark: .alertDark)

    static var other: UIColor = dynamicColor(light: .otherBase, dark: .otherDark)
    static var otherBackground: UIColor = dynamicColor(light: .otherBackgroundBase, dark: .otherBackgroundDark)

    static var constantWhite: UIColor = white
    static var constantBlack: UIColor = black
    static var yellowBase: UIColor = .clrYellowBase

    static var disabledButtonText: UIColor = dynamicColor(light: .fixed40, dark: .fixedBase)
    static var tooltipBackground: UIColor = .fixed110
    static var drawerBackground: UIColor = dynamicColor(light: .constantBlack, dark: .midnight)

    /// Цвет для вьюх (иконок, строк), которые доступны только в qaMode
    static var qaFeature: UIColor = .attention
}
