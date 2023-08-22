//  HighlightAnimationComposition.swift
//  Created by Vladimir Roganov on 18.03.2022.

import UIKit

public struct HighlightAnimationComposition: HighlightAnimationProtocol {
    let anim1: HighlightAnimationProtocol
    let anim2: HighlightAnimationProtocol

    public func animate(isHighlighted: Bool, view: UIView) {
        anim1.animate(isHighlighted: isHighlighted, view: view)
        anim2.animate(isHighlighted: isHighlighted, view: view)
    }
}
