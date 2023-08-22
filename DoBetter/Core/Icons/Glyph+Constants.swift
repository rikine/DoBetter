//
// Created by Никита Шестаков on 06.03.2023.
//

import Foundation

extension Glyph {
    static let email = Glyph(named: "email")!
    static let user = Glyph(named: "user")!
    static let password = Glyph(named: "password")!
    static let logo = Glyph(named: "Logo")!
    static let nothing = Glyph(named: "nothing")!
    static let sorry = Glyph(named: "sorry")!

    static let heart = Glyph(named: "heart")!
    static let heartFill = Glyph(named: "heart.fill")!

    static let tick = Glyph(named: "tick")!
    static let plus = Glyph(named: "plus")!
    static let progress = Glyph(named: "progress")!

    static let settings = Glyph(named: "settings")!
    static let check = Glyph(named: "check")!
    static let remove = Glyph(named: "remove")!

    static let emptyCircle = Glyph(named: "emptyCircle")!
    static let pen = Glyph(named: "pen")!

    static let loupe = Glyph(named: "loupe")!
    static let hidden = Glyph(named: "hidden")!

    static let feed = Glyph(named: "feed")!.changeGlyphSize(size: .square(24))
    static let home = Glyph(named: "home")!.changeGlyphSize(size: .square(24))
    static let empty = Glyph(named: "empty")!.changeGlyphSize(size: .square(244))

    static let warning = Glyph(named: "warning")!
}
