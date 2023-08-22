//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import ViewNodes
import UIKit

final class RoundCornersButton: UIViewWrapper<IBRoundCornersButton>, Initializable {

    var actionClosure: VoidClosure?
    private var spinner: UIViewWrapper<SpinnerView>!

    override init() {
        super.init()
        wrapped.addTarget(self, action: #selector(_action), for: .touchUpInside)
        wrapped.contentMode = .center

        content {
            spinner = .init(.create(style: .lightBackground(.accent), spinnerSize: .square(16))).hidden(true).size(.fill)
        }
    }

    @discardableResult
    func image(_ newValue: UIImage?, imageInsets: UIEdgeInsets = .zero, imageViewContentMode: UIView.ContentMode? = nil) -> Self {
        wrapped.setImage(newValue, for: .normal)
        wrapped.imageEdgeInsets = imageInsets
        imageViewContentMode.let { wrapped.imageView?.contentMode = $0 }

        wrapped.imageView?.stopAnimating()
        guard (newValue?.images?.count ?? 0) > 1 else { return self }
        wrapped.imageView?.startAnimating()
        return self
    }

    @discardableResult
    func icon(_ newValue: IconModel?, imageInsets: UIEdgeInsets = .zero) -> Self {
        image(newValue?.makeImage().withRenderingMode(.alwaysOriginal))
        wrapped.imageEdgeInsets = imageInsets
        wrapped.adjustsImageWhenHighlighted = false
        wrapped.imageView?.stopAnimating()
        return self
    }

    @discardableResult
    func action(_ newValue: VoidClosure?) -> Self {
        actionClosure = newValue
        return self
    }

    @objc
    private func _action() {
        actionClosure?()
    }

    @discardableResult
    func title(_ newValue: String?) -> Self {
        wrapped.titleLabel?.lineBreakMode = .byWordWrapping
        wrapped.titleLabel?.textAlignment = .center
        wrapped.setTitle(newValue, for: .normal)
        return self
    }

    @discardableResult
    func title(_ newValue: NSAttributedString?) -> Self {
        wrapped.setAttributedTitle(newValue, for: .normal)
        return self
    }

    @discardableResult
    func style(_ newValue: IBRoundCornersButton.Style) -> Self {
        wrapped.style = newValue
        return self
    }

    @discardableResult
    func isEnabled(_ newValue: Bool) -> Self {
        wrapped.isEnabled = newValue
        return self
    }

    @discardableResult
    func isForceEnabledStyle(_ newValue: Bool?) -> Self {
        wrapped.isForceEnabledStyle = newValue
        return self
    }

    @discardableResult
    func font(_ newValue: UIFont?) -> Self {
        wrapped.font = newValue
        return self
    }

    @discardableResult
    func buttonCorners(_ newValue: CGFloat?) -> Self {
        wrapped.corners = newValue
        return self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        wrapped.imageView?.stopAnimating()
    }

    struct Model: ViewModel, UpdatableWithoutReloadingRow {
        let text: String?
        let attrText: NSAttributedString?
        let iconModel: IconModel?
        let style: IBRoundCornersButton.Style
        let isEnabled: Bool
        let isForceEnabledStyle: Bool?
        let actionClosure: VoidClosure?
        let height: CGFloat?
        let backgroundColor: UIColor?
        let isLoading: Bool
        let width: CGFloat?

        enum Mode: CaseIterable {
            case remove, add, removeSmall, addSmall

            var title: String {
                switch self {
                case .remove: return Localization.remove.localized
                case .add: return Localization.add.localized
                case .removeSmall: return Localization.removeSmall.localized
                case .addSmall: return Localization.addSmall.localized
                }
            }

            var style: IBRoundCornersButton.Style {
                switch self {
                case .remove, .removeSmall: return .negative
                case .add, .addSmall: return .primary
                }
            }

            var isSmall: Bool { self == .removeSmall || self == .addSmall }

            var buttonSize: CGSize {
                let sizes = (isSmall ? [Mode.removeSmall, .addSmall] : [.remove, .add]).map { $0.title.style(.body.semibold).size() }
                let maxHeight = sizes.map(\.height).max() ?? .zero
                let maxWidth = sizes.map(\.width).max() ?? .zero

                return .init(width: maxWidth + 32, height: maxHeight + 8)
            }

            static func makeModel(for mode: Mode, isLoading: Bool, action: @escaping VoidClosure) -> RoundCornersButton.Model {
                let size = mode.buttonSize

                return .init(text: mode.title,
                             style: isLoading ? .loading : mode.style,
                             isLoading: isLoading,
                             height: size.height,
                             width: size.width,
                             actionClosure: action)
            }
        }

        init(text: String?,
             iconModel: IconModel? = nil,
             style: IBRoundCornersButton.Style = .primary,
             isEnabled: Bool = true,
             isForceEnabledStyle: Bool? = nil,
             isLoading: Bool = false,
             height: CGFloat? = 52,
             width: CGFloat? = nil,
             actionClosure: VoidClosure? = nil,
             backgroundColor: UIColor? = nil) {
            attrText = nil
            self.text = text
            self.iconModel = iconModel
            self.style = style
            self.isEnabled = isEnabled
            self.isForceEnabledStyle = isForceEnabledStyle
            self.actionClosure = actionClosure
            self.height = height
            self.backgroundColor = backgroundColor
            self.isLoading = isLoading
            self.width = width
        }

        init(attrText: NSAttributedString?,
             iconModel: IconModel? = nil,
             style: IBRoundCornersButton.Style = .primary,
             isEnabled: Bool = true,
             isForceEnabledStyle: Bool? = nil,
             isLoading: Bool = false,
             height: CGFloat? = 52,
             width: CGFloat? = nil,
             actionClosure: VoidClosure? = nil,
             backgroundColor: UIColor? = nil) {
            self.attrText = attrText
            text = nil
            self.iconModel = iconModel
            self.style = style
            self.isEnabled = isEnabled
            self.isForceEnabledStyle = isForceEnabledStyle
            self.actionClosure = actionClosure
            self.height = height
            self.backgroundColor = backgroundColor
            self.isLoading = isLoading
            self.width = width
        }

        func setup(view: RoundCornersButton) {
            text.map { view.title($0) } ?? attrText.let { view.title($0) }
            backgroundColor.let { view.background(color: $0) } ?? view.background(color: .clear)
            view.style(style)
                    .isEnabled(isEnabled)
                    .isForceEnabledStyle(isForceEnabledStyle)
                    .action(actionClosure)
            if let height = height {
                view.height(height)
            }
            if let width = width {
                view.width(width)
            }

            if isLoading {
                view.title(nil as String?).style(.loading)
                view.spinner.hidden(false)
            } else {
                view.spinner.hidden(true)
                view.image(nil).style(style).icon(iconModel)
            }
        }
    }
}

extension RoundCornersButton.Model: Equatable {
    public static func ==(lhs: RoundCornersButton.Model, rhs: RoundCornersButton.Model) -> Bool {
        if lhs.text != rhs.text { return false }
        if lhs.iconModel != rhs.iconModel { return false }
        if lhs.style != rhs.style { return false }
        if lhs.isEnabled != rhs.isEnabled { return false }
        if lhs.height != rhs.height { return false }
        if lhs.isLoading != rhs.isLoading { return false }
        return true
    }
}
