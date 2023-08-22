//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import ViewNodes
import UIKit
import CoreGraphics

class Snack: View {
    static let inset: CGFloat = 8

    enum State {
        case hidden, hiding, showing, shown
    }

    private(set) var state: State = .hidden

    var cardHeight: CGFloat { max(0, bounds.size.height - paddingInsets.verticalSum) }

    var hideCompletion: ((Bool) -> Void)?

    private var panGestureRecognizer: UIPanGestureRecognizer?

    /// When removeOnPan is true, panGestureRecognizer will trigger hiding logic and hideCompletion.
    init(removeOnPan: Bool = false) {
        super.init()
        padding(.horizontal(Self.inset))
        if removeOnPan {
            panGestureRecognizer = UIPanGestureRecognizer()
            panGestureRecognizer?.addTarget(self, action: #selector(hideSnack(with:)))
            panGestureRecognizer.let { addGestureRecognizer($0) }
        }
    }

    @objc func hideSnack(with gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            guard state == .shown || state == .showing else { return }
            hide(with: 0.5) { [weak self] _ in
                self?.hideCompletion?(true)
                self?.hideCompletion = nil
            }
        default:
            break
        }
    }

    func hide(with customizedDuration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        guard state != .hiding && state != .hidden else { return }

        if let snackBarContainer = (superview as? SnackBar) {
            state = .hiding
            snackBarContainer.hide(from: self, with: customizedDuration) { [weak self] _ in
                self?.state = .hidden
                completion?(true)
            }
        } else {
            assert(false, "Snack without SnackBar")
        }
    }

    func show(with customizedDuration: TimeInterval? = nil, completion: ((Bool) -> Void)? = nil) {
        guard state != .showing && state != .shown else { return }

        if let snackBarContainer = (superview as? SnackBar) {
            state = .showing
            snackBarContainer.show(from: self, with: customizedDuration) { [weak self] _ in
                self?.state = .shown
                completion?(true)
            }
        } else {
            assert(false, "Snack without SnackBar")
        }
    }

    var hiddenHeight: CGFloat {
        (state == .hidden || state == .hiding) ? cardHeight + Snack.inset : 0
    }
}
