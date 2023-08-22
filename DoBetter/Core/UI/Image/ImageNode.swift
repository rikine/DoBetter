//
// Created by Maxime Tenth on 10/16/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit
import ViewNodes

open class Image: UIViewWrapper<ImageView> {

    public static let defaultCacheMaxAge: TimeInterval = 180 * 24 * 3600

    @discardableResult
    public func image(url: URL?,
                      placeholder: IconModel? = nil,
                      cacheMaxAge: TimeInterval? = nil,
                      downloadCompletion: ((Either<IconModel, Error>) -> Void)? = nil) -> Self {
        wrapped.setImage(with: url, placeholder: placeholder,
                         cacheMaxAge: cacheMaxAge, downloadCompletion: downloadCompletion)
        return self
    }

    @discardableResult
    public func icon(_ model: IconModel?) -> Self {
        wrapped.icon(model)
        return self
    }

    @discardableResult
    public func iconOrHidden(_ model: IconModel?) -> Self {
        hidden(model == nil).icon(model)
        return self
    }

    @discardableResult
    public func contentMode(_ newValue: UIView.ContentMode, for states: [ImageView.State] = [.main, .placeholder]) -> Self {
        states.forEach { wrapped.contentModeByState[$0] = newValue }
        return self
    }

    @discardableResult
    public func contentMode(_ newValue: UIView.ContentMode, for state: ImageView.State) -> Self {
        wrapped.contentModeByState[state] = newValue
        return self
    }

    @discardableResult
    public func imageNamed(_ newValue: String) -> Self {
        image(UIImage(named: newValue))
    }

    @discardableResult
    public func image(_ newValue: UIImage?) -> Self {
        wrapped.icon(IconModel(image: newValue))
        return self
    }

    /// Добавляет дизейбл модель в ImageView
    /// Если != nil, то иконка становится disabled(меняются цвета шейпа, цвета глифа, бордер). PS не робит для картинок из интернета
    @discardableResult
    public func disabledModel(_ newValue: IconModel.DisabledModel?) -> Self {
        wrapped.disabledModel = newValue
        return self
    }

    /// Делает иконку enabled или disabled в зависимости от наличия модели
    @discardableResult
    public func disable(with model: IconModel.DisabledModel?, animated: Bool = false) -> Self {
        disabledModel(model)
        wrapped.icon(wrapped.enabledIconModel, animated: animated)
        return self
    }

    @discardableResult
    public func imageWithConvert(_ newValue: UIImage?) -> Self {
        let convert = wrapped.convert
        let convertedIcon = IconModel(shape: convert?.convertShape(to: newValue?.size ?? .zero),
                                      border: convert?.border,
                                      image: newValue)?.scaledToShape()
        wrapped.icon(convertedIcon)
        return self
    }

    public override func prepareForReuse() {
        wrapped.prepareForReuse()
    }
}
