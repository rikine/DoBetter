//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

//
// Created by Katsz on 23.10.2020.
// Copyright (c) 2020 vision-invest. All rights reserved.
//

import Foundation
import UIKit
import ViewNodes

class CommonSnack: Snack {
    private(set) var card: CommonCard!

    private(set) var imageStack: ZStackWrapper<ImageWithBadge>!
    private(set) var title: Text!
    private(set) var bottomButton: Text!
    private(set) var trailingButton: Text!
    private(set) var closeImageStack: ZStackWrapper<Image>!

    override init(removeOnPan: Bool = false) {
        super.init(removeOnPan: removeOnPan)
        background(color: .clear)
        content {
            card = CommonCard()
                .corner(radius: 12, masksToBounds: false)
                .padding(.all(12))
                .content {
                    HStack()
                        .config(backgroundColor: .clear)
                        .alignment(.center)
                        .width(.fill)
                        .spacing(8)
                        .content {
                            imageStack = ZStackWrapper(contentPosition: .top) {
                                ImageWithBadge()
                            }.height(.fill)

                            _makeTextsHStack()

                            closeImageStack = ZStackWrapper(contentPosition: .top) {
                                Image()
                                    .position(.top)
//                                    .icon(.init(glyph: .close, mode: .smallCircle))
                                    .touchPadding(.all(10))
                            }
                                .height(.fill)
                                .hidden(true)
                        }
                }
        }
    }

    private func _makeTextsHStack() {
        HStack().width(.fill).content {
            VStack().width(.fill).spacing(4).content {
                title = Text().multiline().width(.fill)
                bottomButton = Text().multiline().width(.fill)
            }
            trailingButton = Text()
        }
    }

    // MARK: Setters - Actions

    @discardableResult
    open func onClose(_ value: VoidClosure?) -> Self {
        closeImageStack.contentView.onTap(value)
        closeImageStack.hidden(false)
        return self
    }

    public func apply(model: Model) {
        model.imageModel?.setup(view: imageStack.contentView)
        imageStack.hidden(model.imageModel?.iconModel == nil)

        title.text(model.text)
        bottomButton.textOrHidden(model.bottomButtonText)
        trailingButton.textOrHidden(model.trailingButtonText)
        card.background(color: model.backgroundColor)

        setNeedsLayoutRecursively()

        (superview as? SnackBar).let { $0.apply() }
    }
}

// MARK: - Default Styles
extension CommonSnack.Model {
    static var plainBackgroundColor: UIColor { .elevated }
    static var errorBackgroundColor: UIColor { .destructive }
    static var alertBackgroundColor: UIColor { .foreground }
}

extension CommonSnack {

    struct Model {
        let imageModel: ImageWithBadge.Model?
        let text: NSAttributedString
        let bottomButtonText: NSAttributedString?
        let trailingButtonText: NSAttributedString?
        let backgroundColor: UIColor
        let isClosePossible: Bool

        init(imageModel: ImageWithBadge.Model? = nil,
             text: NSAttributedString,
             bottomButtonText: NSAttributedString? = nil,
             trailingButtonText: NSAttributedString? = nil,
             backgroundColor: UIColor = .elevated,
             isClosePossible: Bool = true) {
            self.imageModel = imageModel
            self.text = text
            self.bottomButtonText = bottomButtonText
            self.trailingButtonText = trailingButtonText
            self.backgroundColor = backgroundColor
            self.isClosePossible = isClosePossible
        }

        init(icon: IconModel?,
             text: NSAttributedString,
             bottomButtonText: NSAttributedString? = nil,
             isClosePossible: Bool = true) {
            self.init(imageModel: .init(iconModel: icon), text: text, bottomButtonText: bottomButtonText)
        }
    }
}

extension CommonSnack.Model: Equatable {
    public static func ==(lhs: CommonSnack.Model, rhs: CommonSnack.Model) -> Bool {
        if lhs.text.string != rhs.text.string { return false }
        if lhs.bottomButtonText != rhs.bottomButtonText { return false }
        if lhs.trailingButtonText != rhs.trailingButtonText { return false }
        return true
    }
}
