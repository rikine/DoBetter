//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

extension String {

    static let nbsp = "\u{00A0}"

    /// The most important thing to remember when working with NSAttributedString, NSRange, and String
    /// is that NSAttributedString (and NSString) and NSRange are based on UTF-16 encoded lengths.
    /// But String and its count are based on actual character counts. They don't mix.
    /// If you ever try to create an NSRange with .count, you will get the wrong range. Always use .utf16.count.
    var fullRange: NSRange { .init(location: 0, length: utf16.count) }

    /// Remove prefix if exists
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// returns type name with namespaces but no bundle name (thanks storyboards)
    /// Now it just remove prefix 'VisionInvest.'
    init<Subject>(reflectingWithoutBundleName subject: Subject) {
        let bundleNameWithDot = (Bundle.main.infoDictionary?["CFBundleName"] as? String).map { $0 + "." }
        let reflectingWithoutBundleName = String(reflecting: subject).removingPrefix(bundleNameWithDot ?? "")
        self.init(reflectingWithoutBundleName)
    }

    func nsRange(of substring: String) -> NSRange? {
        guard let range = self.range(of: substring),
              let lower = UTF16View.Index(range.lowerBound, within: utf16),
              let upper = UTF16View.Index(range.upperBound, within: utf16) else { return nil }
        return NSRange(location: distance(from: utf16.startIndex, to: lower), length: distance(from: lower, to: upper))
    }

    func contains(charactersIn characterSet: CharacterSet) -> Bool {
        rangeOfCharacter(from: characterSet) != nil
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension String {
    func matches(regex: NSRegularExpression?) -> Bool {
        guard let regex = regex else { return false }
        let range = NSRange(startIndex..<endIndex, in: self)
        let match = regex.firstMatch(in: self, range: range)

        return match.map { NSEqualRanges($0.range, range) } ?? false
    }
}

extension NSRegularExpression {
    static let emailRegex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    static let nicknameRegex = try? NSRegularExpression(pattern: "[a-z1-9-_!#&()+\\.]+", options: .caseInsensitive)
    static let passwordRegex = try? NSRegularExpression(pattern: "[a-z1-9!#$()+\\-_*^?]{8,}", options: .caseInsensitive)
}
