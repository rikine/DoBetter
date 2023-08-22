//
// Created by Никита Шестаков on 06.03.2023.
//

import Foundation

extension IconModel {
    enum SingIn {
        static let email = IconModel(glyph: .email.changeGlyphSize(size: .square(24)), glyphTintColor: .foreground)
        static let user = IconModel(glyph: .user.changeGlyphSize(size: .square(20)), glyphTintColor: .foreground)
        static let password = IconModel(glyph: .password.changeGlyphSize(size: .square(24)), glyphTintColor: .foreground)
    }
    
    enum Task {
        static let heart = IconModel(glyph: .heart, glyphTintColor: .foreground).glyphSize(.square(32))
        static let heartFill = IconModel(glyph: .heartFill, glyphTintColor: .foreground).glyphSize(.square(32))
        static let plus = IconModel(glyph: .plus, glyphTintColor: .foreground).glyphSize(.square(24))
        static let tick = IconModel(glyph: .tick, glyphTintColor: .foreground).glyphSize(.square(16))
        static let progress = IconModel(glyph: .progress, glyphTintColor: .foreground).glyphSize(.square(16))
        static let check = IconModel(glyph: .check, glyphTintColor: .foreground)
        static let remove = IconModel(glyph: .remove, glyphTintColor: .foreground)
        static let emptyCircle = IconModel(glyph: .emptyCircle, glyphTintColor: .foreground)
        static let home = IconModel(glyph: .home, glyphTintColor: .foreground)
        static let feed = IconModel(glyph: .feed, glyphTintColor: .foreground)
        static let empty = IconModel(glyph: .empty, glyphTintColor: .foreground)
    }

    enum User {
        static let settings = IconModel(glyph: .settings, glyphTintColor: .foreground).glyphSize(.square(20))
        static let pen = IconModel(glyph: .pen, glyphTintColor: .foreground).glyphSize(.square(20))
        static let loupe = IconModel(glyph: .loupe, glyphTintColor: .foreground).glyphSize(.square(20))
        static let hidden = IconModel(glyph: .hidden, glyphTintColor: .foreground).glyphSize(.square(20))
    }
}