//
//  NSAttributedString+TextLines.swift
//  VisionInvestUtils
//
//  Created by Вадим Серегин on 29.11.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import UIKit

/// часть отсюда https://stackoverflow.com/questions/27683559/number-of-rendered-lines-for-uilabel-with-fixed-width-and-nsattributedstring
/// а часть с вырезанием `lineBreakMode` @art-off
public extension NSAttributedString {
    /// For multiline text rendered in given `width`, get CTLine objects for each line for further processing
    func getCTLines(width: CGFloat) -> [CTLine] {
        /// Объяснение почему мы удаляем `lineBreakMode` на время расчета
        ///
        /// Если значение `lineBreakMode` будет равно одному из следующих:
        /// - `.byTruncatingHead`
        /// - `.byTruncatingTail`
        /// - `.byTruncatingMiddle`
        /// То этот калькулятор будет думать так: "Ну я могу сделать так, чтобы у меня строка вместилась в одну линию, а в конце будет многоточие"
        /// и в принципе он будет прав.
        ///
        /// Но это не самое `ожидаемое` поведение, поэтому пришлось вырезать это поле на время расчета

        let paragraphStyle = self.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSMutableParagraphStyle

        // Сохраняем значение `lineBreakMode` и ставим на дефолтное на время расчета
        let cacheLineBreakMode: NSLineBreakMode?
        cacheLineBreakMode = paragraphStyle?.lineBreakMode
        paragraphStyle?.lineBreakMode = .byWordWrapping

        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT)))
        let frameSetterRef : CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef: CTFrame = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path.cgPath, nil)

        let linesNS: NSArray  = CTFrameGetLines(frameRef)

        // Снова восстанавливаем старое значение
        cacheLineBreakMode.let { paragraphStyle?.lineBreakMode = $0 }

        return linesNS as? [CTLine] ?? []
    }

    func numberOfLines(width: CGFloat) -> Int {
        getCTLines(width: width).count
    }

    /// Calculating number of lines with some text(letters or numbers) in a range of lines.
    ///
    /// - Parameters:
    ///   - ctLines: First n CTLines
    ///   - width: width of the containing label
    /// - Returns: Number of text lines (without any spare lines).
    /// Part with getting string from a CTLine was taken from here.
    /// https://stackoverflow.com/questions/4421267/how-to-get-text-string-from-nth-line-of-uilabel
    func numberOfTextLines(inFirst ctLinesNum: Int? = nil, width: CGFloat) -> Int {
        var linesArray = [String]()
        /// 1. Get line objects rendered with specific width
        var linesNS = getCTLines(width: width)
        /// 2. Then, selecting first n lines.
        if let ctLinesNum = ctLinesNum {
            linesNS = Array(linesNS.prefix(ctLinesNum))
        }
        for line in linesNS {
            /// 3. Getting range of the string part, corresponding to specific line of the label.
            let lineRange: CFRange = CTLineGetStringRange(line)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            /// 4. Finding the string on a line.
            let lineString: String = (self.string as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        /// 5. Calculating how many of lines contain alphanumerics
        return linesArray.filter { $0.contains(charactersIn: .alphanumerics) }.count
    }

    func linesNumberIgnoringBlankLines(neededTextLines: Int, width: CGFloat) -> Int {
        /// Current number of lines including lines without any text.
        var lines = neededTextLines
        /// Current number of lines with text.
        var currentNumberOfTextLines = numberOfTextLines(inFirst: lines, width: width)

        while currentNumberOfTextLines < neededTextLines {
            lines += 1
            currentNumberOfTextLines = numberOfTextLines(inFirst: lines, width: width)
        }
        return lines
    }

    func boundingRect(with size: CGSize = .init(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude))
        -> CGRect {
        boundingRect(with: size,
                     options: .usesLineFragmentOrigin,
                     context: nil)
    }

    /// Calculate text height for given `width` for `linesCount` at most
    func textHeight(for width: CGFloat, linesCount: Int?) -> CGFloat {
        guard length > 0 else { return 0 }

        // If no linesCount provided, calculate full height
        guard let linesCount = linesCount else { return textHeight(for: width) }

        // Check that we are using maximum available lines
        let ctLines = getCTLines(width: width)
        let availableLines = min(ctLines.count, linesCount)

        // Compute total height for N lines
        return ctLines.prefix(availableLines)
            .map { typographicSize(line: $0).height }
            .sum()
    }

    func textHeight(for width: CGFloat = UIScreen.main.bounds.width) -> CGFloat {
        boundingRect(with: .init(width: width, height: .greatestFiniteMagnitude)).height
    }
}

public func typographicSize(line: CTLine) -> CGSize {
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var leading: CGFloat = 0

    let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
    return CGSize(width: width, height: ascent + descent + leading)
}
