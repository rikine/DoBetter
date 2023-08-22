//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

final class SpinnerView: UIView {

    let style: ActivityIndication.Style

    private let _label: UILabel

    var message: NSAttributedString? {
        get {
            return _label.attributedText
        }
        set {
            _label.isHidden = newValue == nil
            _label.attributedText = newValue
        }
    }

    func setMessage(_ message: NSAttributedString?, animated: Bool) {
        if animated {
            UIView.transition(with: self,
                              duration: Animation.Duration.default,
                              options: [.curveEaseInOut, .transitionCrossDissolve],
                              animations: { self.message = message }, completion: nil)
        } else {
            self.message = message
        }
    }

    private init(style: ActivityIndication.Style, spinnerSize: CGSize? = nil) {

        self.style = style
        _label = UILabel()
        _label.isHidden = true
        _label.numberOfLines = 0

        super.init(frame: .zero)

        let animatingImage: UIImage

        switch style {
        case .darkBackground(let color):
            animatingImage = color.image
            backgroundColor = .clear
            _label.textColor = .white
        case let .lightBackground(background):
            animatingImage = UIImage.ActivityIndication.whiteSpiner
            backgroundColor = background
            _label.textColor = .foreground2
        }

        let imageView = SpinnerImageView(image: animatingImage)

        let stackView = UIStackView(arrangedSubviews: [imageView, _label])
        stackView.axis = .vertical
        stackView.alignment = .center

        addSubview(stackView, constraints: .center)

        let heightAnchor = spinnerSize?.height ?? ActivityIndicatorController.spinnerImageHeight

        imageView.setConstraintsForSelf(
            .equal(\.widthAnchor, \.heightAnchor, multiplier: animatingImage.size.width / animatingImage.size.height),
            .equalToConstant(\.heightAnchor, heightAnchor)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func create(style: ActivityIndication.Style, spinnerSize: CGSize? = nil) -> SpinnerView {
        SpinnerView(style: style, spinnerSize: spinnerSize)
    }
}

// When spinner placed in UITableViewCell, it may disappear after dequeueReusableCellWithIdentifier
// because removeAllAnimations will be called, we override this method with empty one to prevent disappear

private class SpinnerImageView: UIImageView {
    class SpinnerLayer: CALayer {
        override func removeAllAnimations() {}
    }

    override class var layerClass: AnyClass { SpinnerLayer.self }
}
