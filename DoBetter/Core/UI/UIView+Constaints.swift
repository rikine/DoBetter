//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

/// This structure provides a namespace for the builder functions.
struct Constraint {

    fileprivate typealias ConstraintBuilder = (UIView, UIView) -> NSLayoutConstraint

    fileprivate let _constraintBuilder: ConstraintBuilder

    private init(_ constraintBuilder: @escaping ConstraintBuilder) {
        _constraintBuilder = constraintBuilder
    }

    // MARK: - Equal overloads

    static func equal<Axis, Anchor: NSLayoutAnchor<Axis>>(_ fromKeyPath: KeyPath<UIView, Anchor>,
                                                          _ anchor: Anchor,
                                                          constant: CGFloat = 0) -> Constraint {
        Constraint { view, _ in
            view[keyPath: fromKeyPath].constraint(equalTo: anchor, constant: constant)
        }
    }

    static func equal<Axis, Anchor: NSLayoutAnchor<Axis>>(_ fromKeyPath: KeyPath<UIView, Anchor>,
                                                          _ toKeyPath: KeyPath<UIView, Anchor>,
                                                          constant: CGFloat = 0) -> Constraint {
        Constraint { $0[keyPath: fromKeyPath].constraint(equalTo: $1[keyPath: toKeyPath], constant: constant) }
    }

    static func equal<Axis, Anchor: NSLayoutAnchor<Axis>>(_ keyPath: KeyPath<UIView, Anchor>,
                                                          constant: CGFloat = 0) -> Constraint {
        equal(keyPath, keyPath, constant: constant)
    }

    static func equal<Dimention: NSLayoutDimension>(_ fromKeyPath: KeyPath<UIView, Dimention>,
                                                    _ toKeyPath: KeyPath<UIView, Dimention>,
                                                    multiplier: CGFloat = 1,
                                                    constant: CGFloat = 0) -> Constraint {
        Constraint {
            $0[keyPath: fromKeyPath].constraint(equalTo: $1[keyPath: toKeyPath],
                                                multiplier: multiplier,
                                                constant: constant)
        }
    }

    static func equal<Dimention: NSLayoutDimension>(_ keyPath: KeyPath<UIView, Dimention>,
                                                    multiplier: CGFloat = 1,
                                                    constant: CGFloat = 0) -> Constraint {
        equal(keyPath, keyPath, multiplier: multiplier, constant: constant)
    }

    static func equalToConstant<Dimention: NSLayoutDimension>(_ keyPath: KeyPath<UIView, Dimention>,
                                                              _ constant: CGFloat) -> Constraint {
        Constraint { item, _ in
            item[keyPath: keyPath].constraint(equalToConstant: constant)
        }
    }

    // MARK: - Greater than or equal overloads

    static func greaterThanOrEqual<Axis, Anchor: NSLayoutAnchor<Axis>>(_ fromKeyPath: KeyPath<UIView, Anchor>,
                                                                       _ toKeyPath: KeyPath<UIView, Anchor>,
                                                                       constant: CGFloat = 0) -> Constraint {
        Constraint {
            $0[keyPath: fromKeyPath].constraint(greaterThanOrEqualTo: $1[keyPath: toKeyPath], constant: constant)
        }
    }

    static func greaterThanOrEqual<Axis, Anchor: NSLayoutAnchor<Axis>>(_ keyPath: KeyPath<UIView, Anchor>,
                                                                       constant: CGFloat = 0) -> Constraint {
        greaterThanOrEqual(keyPath, keyPath, constant: constant)
    }

    static func greaterThanOrEqualToConstant<Dimention: NSLayoutDimension>(_ keyPath: KeyPath<UIView, Dimention>,
                                                                           _ constant: CGFloat) -> Constraint {
        Constraint { item, _ in
            item[keyPath: keyPath].constraint(greaterThanOrEqualToConstant: constant)
        }
    }

    // MARK: - Less than or equal overloads

    static func lessThanOrEqual<Axis, Anchor: NSLayoutAnchor<Axis>>(_ fromKeyPath: KeyPath<UIView, Anchor>,
                                                                    _ toKeyPath: KeyPath<UIView, Anchor>,
                                                                    constant: CGFloat = 0) -> Constraint {
        Constraint {
            $0[keyPath: fromKeyPath].constraint(lessThanOrEqualTo: $1[keyPath: toKeyPath], constant: constant)
        }
    }

    static func lessThanOrEqual<Axis, Anchor: NSLayoutAnchor<Axis>>(_ keyPath: KeyPath<UIView, Anchor>,
                                                                    constant: CGFloat = 0) -> Constraint {
        lessThanOrEqual(keyPath, keyPath, constant: constant)
    }
}

extension Array where Element == Constraint {

    static let fill: [Constraint] = [.equal(\.leadingAnchor),
                                     .equal(\.topAnchor),
                                     .equal(\.trailingAnchor),
                                     .equal(\.bottomAnchor)]

    static func fill(withInsets insets: UIEdgeInsets) -> [Constraint] {
        [.equal(\.leadingAnchor, constant: insets.left),
         .equal(\.topAnchor, constant: insets.top),
         .equal(\.trailingAnchor, constant: -insets.right),
         .equal(\.bottomAnchor, constant: -insets.bottom)]
    }

    static let fillToMargins: [Constraint] = [.equal(\.topAnchor, \.layoutMarginsGuide.topAnchor),
                                              .equal(\.bottomAnchor, \.layoutMarginsGuide.bottomAnchor),
                                              .equal(\.leadingAnchor, \.layoutMarginsGuide.leadingAnchor),
                                              .equal(\.trailingAnchor, \.layoutMarginsGuide.trailingAnchor)]

    static let fillTopToBottom: [Constraint] = [.equal(\.topAnchor, \.layoutMarginsGuide.topAnchor),
                                                .equal(\.bottomAnchor, \.layoutMarginsGuide.bottomAnchor),
                                                .equal(\.leadingAnchor),
                                                .equal(\.trailingAnchor)]

    static let center: [Constraint] = [.equal(\.centerXAnchor),
                                       .equal(\.centerYAnchor)]

    static let equalSize: [Constraint] = [.equal(\.heightAnchor),
                                          .equal(\.widthAnchor)]

    static func bottomSeparator(leadingOffset: CGFloat = 0,
                                trailingOffset: CGFloat = 0,
                                thickness: CGFloat = 1) -> [Constraint] {
        [
            .equal(\.bottomAnchor),
            .equal(\.trailingAnchor, constant: trailingOffset),
            .equalToConstant(\.heightAnchor, thickness),
            .equal(\.leadingAnchor, constant: leadingOffset)
        ]
    }

    static func topSeparator(leadingOffset: CGFloat = 0,
                             trailingOffset: CGFloat = 0,
                             thickness: CGFloat = 1) -> [Constraint] {
        [
            .equal(\.topAnchor),
            .equal(\.trailingAnchor, constant: trailingOffset),
            .equalToConstant(\.heightAnchor, thickness),
            .equal(\.leadingAnchor, constant: leadingOffset)
        ]
    }
}

extension UIView {

    @discardableResult
    func al() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    @discardableResult
    func applyConstraints(with other: UIView,
                          constraints: Constraint...,
                          activated: Bool = true) -> [NSLayoutConstraint] {
        applyConstraints(with: other, constraints: constraints, activated: activated)
    }

    @discardableResult
    func applyConstraints(with other: UIView,
                          constraints: [Constraint],
                          activated: Bool = true) -> [NSLayoutConstraint] {
        other.translatesAutoresizingMaskIntoConstraints = false
        let builtContraints = constraints.map { $0._constraintBuilder(other, self) }
        if activated {
            NSLayoutConstraint.activate(builtContraints)
        }
        return builtContraints
    }

    // MARK: - addSubview overloads

    @discardableResult
    func addSubview(_ subview: UIView, constraints: Constraint..., activated: Bool = true) -> [NSLayoutConstraint] {
        addSubview(subview, constraints: constraints, activated: activated)
    }

    @discardableResult
    func addSubview(_ subview: UIView, constraints: [Constraint], activated: Bool = true) -> [NSLayoutConstraint] {
        addSubview(subview)
        return applyConstraints(with: subview, constraints: constraints, activated: activated)
    }

    func fillSafeArea(of viewController: UIViewController, with subview: UIView) {
        subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true

        NSLayoutConstraint(item: subview,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: subview,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 0).isActive = true
    }

    // MARK: - insertSubview overloads

    @discardableResult
    func insertSubview(_ view: UIView, at index: Int, constraints: Constraint...) -> [NSLayoutConstraint] {
        insertSubview(view, at: index, constraints: constraints)
    }

    @discardableResult
    func insertSubview(_ view: UIView, at index: Int, constraints: [Constraint]) -> [NSLayoutConstraint] {
        insertSubview(view, at: index)
        return applyConstraints(with: view, constraints: constraints)
    }

    // MARK: - Setting constraints for self

    @discardableResult
    func setConstraintsForSelf(_ constraints: Constraint...) -> [NSLayoutConstraint] {
        setConstraintsForSelf(constraints)
    }

    @discardableResult
    func setConstraintsForSelf(_ constraints: [Constraint]) -> [NSLayoutConstraint] {
        applyConstraints(with: self, constraints: constraints)
    }
}
