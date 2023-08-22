//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public struct Glyph: Equatable {

    private let _image: UIImage

    public var image: UIImage { // if image is animated just return image
        _image.images.map { _ in _image } ?? _image.imageAsset?.image(with: .current) ?? _image
    }

    private init() {
        _image = .init()
    }

    public init?(image: UIImage?) {
        guard let image = image else { return nil }
        _image = image
    }

    public init?(named name: String) {
        self.init(image: .init(named: name))
    }

    public func scaled(to targetSize: CGSize) -> Glyph {
        let image: UIImage

        if let images = _image.images, images.count > 1 {
            image = UIImage.animatedImage(with: images.map { $0.scale(to: targetSize) }, duration: _image.duration) ?? UIImage()
        } else if let asset = _image.imageAsset {
            image = asset.image(with: .light).scale(to: targetSize)
            let dark = asset.image(with: .dark).scale(to: targetSize)
            image.imageAsset?.register(dark, with: .init(traitsFrom: [.current, .init(userInterfaceStyle: .dark)]))
        } else {
            image = _image.scale(to: targetSize)
        }
        return Glyph(image: image) ?? Glyph()
    }
}

public extension Glyph {

    static func empty(ofSize size: CGSize) -> Glyph {
        Glyph(image: UIImage.from(color: .clear, size: size))!
    }

    static let smallSize = CGSize.square(16)
    static let regularSize = CGSize.square(24)
    static let mediumSize = CGSize.square(36)
    static let largeSize = CGSize.square(48)

    var small: Glyph {
        changeGlyphSize(size: Self.smallSize)
    }

    var regular: Glyph {
        changeGlyphSize(size: Self.regularSize)
    }

    var medium: Glyph {
        changeGlyphSize(size: Self.mediumSize)
    }

    var large: Glyph {
        changeGlyphSize(size: Self.largeSize)
    }

    func changeGlyphSize(size: CGSize) -> Glyph {
        let glyph = self
        return glyph.scaled(to: size)
    }

    var size: CGSize { image.size }
}
