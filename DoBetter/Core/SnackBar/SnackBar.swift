//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import ViewNodes
import UIKit
import CoreGraphics

class SnackBar: ZStack {
    /// Define logic of snackBar hiding using gestures.
    enum HideGestureMode {
        /// Hiding when scrolling a scrollView.
        case showHideOnScroll(UIPanGestureRecognizer)
        /// No hiding with gestures.
        case `default`
    }

    enum Position {
        case top, bottom
    }

    static let bottomSnackBarPaddingInset: CGFloat = 0
    var topSnackBarPaddingInset: CGFloat = 0
    static let hiddenTransformHeight: CGFloat = 500

    let animationDuration: TimeInterval

    var hiddenTransformHeight: CGFloat {
        positionValue == .bottom ? Self.hiddenTransformHeight : -Self.hiddenTransformHeight
    }

    var snacks: [Snack] = [] {
        didSet {
            let padding: UIEdgeInsets = positionValue == .bottom
                ? .bottom(Self.bottomSnackBarPaddingInset)
                : .top(topSnackBarPaddingInset)
            self.padding(padding)
            removeSubviews()
            setNeedsLayout()
            layoutIfNeeded()
            invalidateIntrinsicContentSize()
            snacks.reversed().forEach { addSubnode($0) }
        }
    }

    private(set) var isRefreshing: Bool = false
    let hideGestureMode: HideGestureMode
    /// If SnackBar is frozen it will not show/hide itself automatically, regardless specified style
    var frozen: Bool = false

    var invalidateIntrinsicContentSizeWhenApplyModel: Bool = true

    init(_ hideGestureMode: HideGestureMode = .default, position: Position = .bottom, animationDuration: TimeInterval = 1) {
        self.hideGestureMode = hideGestureMode
        self.animationDuration = animationDuration
        super.init()
        background(color: .clear)
        let viewPosition: View.Position = position == .bottom ? .bottom : .top
        self.position(viewPosition)

        switch hideGestureMode {
        case .showHideOnScroll(let gesture):
            gesture.addTarget(self, action: #selector(showHide(with:)))
        case .default: break
        }
    }

    var containerHeight: CGFloat {
        // Берём высоту всех видимых снеков + инсет на каждый видимый снек + инсет самого снекбара
        snacks.filter(where: \.state, is: .shown).map { $0.cardHeight + Snack.inset }.sum() +
            paddingInsets.verticalSum
    }

    /// Sum of snacks' heights that are hidden and above the snack with snackIndex
    func hiddenSnacksHeight(for snackIndex: Int) -> CGFloat {
        guard snackIndex > 0 else { return 0 }
        let absHeight = snacks[0..<snackIndex].reduce(0) { result, snack in
            result + snack.hiddenHeight
        }
        return positionValue == .bottom ? absHeight : -absHeight
    }

    @objc private func showHide(with pan: UIPanGestureRecognizer) {
        guard !frozen else { return }

        switch pan.state {
        case .cancelled, .ended, .failed, .possible:
            showHideContainer(show: true)
        case .began:
            showHideContainer(show: false)
        default:
            break
        }
    }

    // Оверрайдим hitTest для проброса касаний в нижележащие вьюхи
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

    func apply() {
        setNeedsLayout()
        layoutIfNeeded()
        if invalidateIntrinsicContentSizeWhenApplyModel {
            invalidateIntrinsicContentSize()
        }
    }

    /// Перестроение контейнера
    /// Вызывается снекбаром в момент скрытия снекбара
    ///
    /// - Parameter initiator: SnackBar внутри контейнера, который запустил перестроение
    func hide(from initiator: Snack, with customizedDuration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        showHide(from: initiator, show: false, with: customizedDuration, completion: completion)
    }

    /// Перестроение контейнера
    /// Вызывается снекбаром в момент появления снекбара
    ///
    /// - Parameter initiator: SnackBar внутри контейнера, который запустил перестроение
    func show(from initiator: Snack, with customizedDuration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        showHide(from: initiator, show: true, with: customizedDuration, completion: completion)
    }

    private func showHide(from initiator: Snack, show: Bool, with customizedDuration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        guard snacks.contains(initiator) else { return }

        var heights: [CGFloat] = []
        for (index, snack) in snacks.enumerated() {
            let height: CGFloat
            switch snack.state {
            case .hidden, .hiding:
                height = hiddenTransformHeight
            case .showing, .shown:
                height = hiddenSnacksHeight(for: index)
            }
            heights.append(height)
        }

        animate(transformHeights: heights, with: customizedDuration, completion: completion)
    }

    private func showHideContainer(show: Bool) {
        UIView.animate(withDuration: animationDuration) { () -> Void in
            self.transform = show ? .identity : CGAffineTransform(translationX: 0, y: self.hiddenTransformHeight)
        }
    }

    private func animate(transformHeights: [CGFloat], with customizedDuration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        isRefreshing = true
        UIView.animate(withDuration: customizedDuration ?? animationDuration, delay: 0, options: [.beginFromCurrentState], animations: ({ () -> Void in
            zip(self.snacks, transformHeights).forEach { snack, height in
                snack.transform = CGAffineTransform(translationX: 0, y: height)
            }
        }), completion: ({ (b) -> Void in
            completion?(b)
            self.isRefreshing = false
        }))
    }

    override func layoutSubviews() {
        let snacksHeights: [CGFloat] = snacks.map(\.cardHeight)

        for (index, snack) in snacks.enumerated() {
            snack.position(positionValue)

            let paddingHeight: CGFloat = index > 0
                ? Array(snacksHeights[0...index - 1]).sum() + CGFloat(index + 1) * Snack.inset
                : Snack.inset
            let padding: UIEdgeInsets = positionValue == .bottom ? .bottom(paddingHeight) : .top(paddingHeight)
            snack.padding(.left(snack.paddingInsets.left) + .right(snack.paddingInsets.right) + padding)

            let transformHeight: CGFloat = (snack.state == .hidden || snack.state == .hiding)
                ? hiddenTransformHeight
                : hiddenSnacksHeight(for: index)
            snack.transform = CGAffineTransform(translationX: 0, y: transformHeight)
        }
        super.layoutSubviews()
    }

    // MARK: - This is to make friends AutoLayout and ViewNodes
    override var intrinsicContentSize: CGSize {
        sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.infinity))
    }
}

protocol SnackBarProvider: AnyObject {
    var topSnackBar: SnackBar! { get }
    var bottomSnackBar: SnackBar! { get }
}
