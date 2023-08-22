//
// Created by Никита Шестаков on 28.04.2023.
//

import Foundation
import ViewNodes
import UIKit
@testable import DoBetter

class TestUtils {
    static func setupSut<T: View, P: View>(
        _ sutProducer: @autoclosure () -> T,
        _ parentProducer: @autoclosure  () -> P = ZStack()
    ) -> (sut: T, sutParent: P) {
        let sut = sutProducer()
        let parent = parentProducer()
        
        if parent is VStack || parent is HStack {
            (parent as? Stack)?.addArrangedSubview(sut)
        } else {
            parent.addSubnode(sut)
        }
        parent.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        parent.layoutIfNeeded()
        return (sut, parent)
    }

    static func testString(count: Int) -> String {
        String(repeating: "test ", count: count)
    }

    static func testStrings(_ lenghts: [Int] = .defaultTestStringLenghts, withNils: Bool = false) -> [String?] {
        lenghts.map { (withNils ? Bool.random() : false) ? nil : testString(count: $0) }
    }
    
    static func testIcons(count: Int = [Int].defaultTestStringLenghts.count, size: CGFloat, withNils: Bool = false) -> [IconModel?] {
        (0..<count).map { _ in (withNils ? Bool.random() : false) ? nil : .empty(ofSize: size) }
    }
}

public extension Array<Int> {
    static var defaultTestStringLenghts = [0, 4, 10, 40]
}


public extension UIView {

    var topParent: UIView? {
        var parent = superview
        while parent?.superview != nil {
            parent = parent?.superview
        }
        return parent
    }

    var absoluteFrame: CGRect {
        guard let topParent else { return frame }
        return convert(bounds, to: topParent)
    }
}

extension IconModel {
    static func empty(ofSize size: CGFloat) -> Self {
        empty(ofSize: .square(size))
    }

    static func empty(ofSize size: CGSize) -> Self {
        IconModel(glyph: Glyph.empty(ofSize: size))
    }
}

extension String {
    var toAttrString: NSAttributedString {
        style(.title)
    }
}
