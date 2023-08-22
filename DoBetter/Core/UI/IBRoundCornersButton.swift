//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

@IBDesignable
final class IBRoundCornersButton: UIButton {

    @objc enum Style: Int {
        case primary = 1
        case secondary = 2
        case negative = 3
        case text = 4
        case loading = 5
        case secondaryNegative = 6
    }

    @IBInspectable dynamic var style: Style = .primary {
        didSet {
            _configure()
        }
    }

    // MARK: - Customizable properties

    var corners: CGFloat? {
        didSet {
            _configure()
        }
    }

    var font: UIFont? {
        didSet {
            _configure()
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        _configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        _configure()
    }

    override var isEnabled: Bool {
        didSet {
            _configure()
        }
    }

    var isForceEnabledStyle: Bool?

    override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            super.isHighlighted = newValue

            UIView.animate(withDuration: 0.2, animations: {
                self._configure()
                self.transform = self.transform.scaledBy(x: 1.02, y: 1.02)
            }) { [weak self] _ in
                UIView.animate(withDuration: 0.2) {
                    self?.transform = .identity
                }
            }
        }
    }

    private func _configure() {
        layer.cornerRadius = corners ?? 12
        titleLabel?.font = font ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        _updateBackground()
        _updateTextColor()
    }

    private var _isEnabledForStyling: Bool {
        isForceEnabledStyle ?? isEnabled
    }

    private func _updateBackground() {
        let color = style.backgroundFor(enabled: _isEnabledForStyling)
        layer.backgroundColor = color.cgColor
        alpha = isHighlighted ? 0.7 : 1
    }

    private func _updateTextColor() {
        let textColor = style.textColor(enabled: _isEnabledForStyling)
        setTitleColor(textColor, for: state)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _configure()
    }
}

extension IBRoundCornersButton.Style {

    func backgroundFor(enabled: Bool) -> UIColor {
        switch self {
        case .primary:
            return .accent
        case .secondary:
            return .content2
        case .negative, .text:
            return .clear
        case .loading:
            return .foreground3
        case .secondaryNegative:
            return .destructive
        }
    }

    func textColor(enabled: Bool) -> UIColor {
        if enabled {
            switch self {
            case .primary, .secondaryNegative:
                return .white
            case .secondary, .text:
                return .accent
            case .negative:
                return .destructive
            case .loading:
                return .foreground
            }
        } else {
            return .disabledButtonText
        }
    }
}
