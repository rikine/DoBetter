//
// Created by Vasiliy Samarin on 13.12.2022.
// Copyright (c) 2022 vision-invest. All rights reserved.
//

public enum HighlightAnimations {
    var `protocol`: HighlightAnimationProtocol {
        switch self {
        case .alphaTouch: return HighlightAnimation.alphaTouch
        case .scaleTouch: return HighlightAnimation.scaleTouch
        case .scaleAndAlpha: return HighlightAnimation.scaleAndAlpha
        }
    }

    case alphaTouch, scaleTouch, scaleAndAlpha
}
