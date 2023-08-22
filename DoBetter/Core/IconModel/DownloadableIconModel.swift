//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

public typealias FICardModelIconData = (URL?, IconModel?)

public struct DownloadableIconModel: Equatable {
    public let url: URL?
    public let placeholder: IconModel?
    public let style: DownloadableIconStyle
    public let convert: ImageConverter?

    public init(url: URL?,
                placeholder: IconModel?,
                style: DownloadableIconStyle = .common,
                convert: ImageConverter? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.style = style
        self.convert = convert
    }

    public init(from iconData: FICardModelIconData, style: DownloadableIconStyle = .common, convert: ImageConverter? = nil) {
        self.init(url: iconData.0, placeholder: iconData.1, style: style, convert: convert)
    }
}

extension DownloadableIconModel: AnyIconModel {
    public func setupIcon(_ icon: Image) {
        icon.image(self)
    }
}

extension Image {
    @discardableResult
    public func image(_ model: DownloadableIconModel?, converter: ImageConverter? = nil) -> Self {
        guard let model = model else {
            wrapped.setImage(with: nil)
            return self
        }
        wrapped.convert = converter ?? model.style.process
        wrapped.setImage(with: model.url, placeholder: model.placeholder, cacheMaxAge: Image.defaultCacheMaxAge)
        return self
    }
}
