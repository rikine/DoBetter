//  HighlightAnimation.swift
//  Created by Vladimir Roganov on 18.03.2022.

import UIKit

/// Базовая реализация `HighlightAnimationProtocol` для воспроизведения отклика на тач
/// Пример использования: `someView.highlightAnimation = HighlightAnimation.alphaTouch` - снизит alpha на `.touchBegan`, и вернет к прежнему значению на `.touchCanceled || .touchEnded`
public struct HighlightAnimation: HighlightAnimationProtocol {
    public struct Params {
        let fromValue: CGFloat
        let toValue: CGFloat
        let duration: TimeInterval
        let delayBackwardsAnimation: Bool
    }
    let params: Params
    let beforeAnim: (_ isHighlighted: Bool, _ view: UIView, _ params: Params) -> Void
    let animation: (_ isHighlighted: Bool, _ view: UIView, _ params: Params) -> Void

    public func animate(isHighlighted: Bool, view: UIView) {
        beforeAnim(isHighlighted, view, params)
        let delay = isHighlighted ? 0.0 : 0.1
        UIView.animate(withDuration: params.duration, delay: params.delayBackwardsAnimation ? delay : 0.0) {
            animation(isHighlighted, view, params)
        }
    }

    public static var alphaTouch: HighlightAnimationProtocol {
        HighlightAnimation(params: .init(fromValue: 1.0, toValue: 0.4, duration: 0.2, delayBackwardsAnimation: true),
                           beforeAnim: { isHighlighted, view, params in
            view.alpha = isHighlighted ? params.fromValue : params.toValue
        },
                           animation: { isHighlighted, view, params in
            view.alpha = isHighlighted ? params.toValue : params.fromValue
        })
    }

    public static var scaleTouch: HighlightAnimationProtocol {
        HighlightAnimation(params: .init(fromValue: 1.0, toValue: 0.96, duration: 0.2, delayBackwardsAnimation: true),
                           beforeAnim: { isHighlighted, view, params in
            view.transform = CGAffineTransform.identity(scaled: isHighlighted ? params.fromValue : params.toValue)
        },
                           animation: { isHighlighted, view, params in
            view.transform = CGAffineTransform.identity(scaled: isHighlighted ? params.toValue : params.fromValue)
        })
    }

    public static var scaleAndAlpha: HighlightAnimationProtocol {
        HighlightAnimationComposition(anim1: HighlightAnimation.alphaTouch, anim2: HighlightAnimation.scaleTouch)
    }
}
