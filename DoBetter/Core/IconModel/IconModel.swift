//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit
import ViewNodes

public struct IconModel: Equatable, Updatable {

    // MARK: - Properties

    private(set) public var shape: Shape?
    private(set) public var shapeColor: UIColor
    private(set) public var border: Border?
    private(set) public var glyph: Glyph
    private(set) public var glyphTintColor: UIColor?

    public var size: CGSize { (shape?.size ?? glyph.size) + paddingInsets.size }
    private(set) public var paddingInsets: UIEdgeInsets

    public var toNewAttrString: AttrString { "\(icon: self)" }

    /// Padding is for the shape and the glyph.
    public init(shape: Shape? = nil, shapeColor: UIColor = .background, border: Border? = nil,
                glyph: Glyph, glyphTintColor: UIColor? = nil, padding: UIEdgeInsets = .zero) {
        self.shape = shape
        self.shapeColor = shapeColor
        self.border = border
        self.glyph = glyph
        self.glyphTintColor = glyphTintColor
        paddingInsets = padding
    }

    public init(glyph: Glyph,
                mode: IconModelMode,
                glyphTintColor: UIColor? = nil,
                shapeColor: UIColor = .background) {
        self.init(shape: mode.shape,
                  shapeColor: .background,
                  glyph: mode.scale(glyph: glyph),
                  glyphTintColor: glyphTintColor)
    }

    /// Using this to create basically any icon which need custom border or background. Main motivation is dark mode compatability.
    public init?(shape: Shape? = nil, shapeColor: UIColor = .clear, border: Border? = nil, image: UIImage?, padding: UIEdgeInsets = .zero) {
        guard let image = image, let glyph = Glyph(image: image) else { return nil }
        self.init(shape: shape, shapeColor: shapeColor, border: border, glyph: glyph)
    }

    /// Init for a shape without any image. Ex: placeholder
    public init(shape: Shape, shapeColor: UIColor, padding: UIEdgeInsets = .zero, border: Border? = nil) {
        let image = UIImage.from(color: .clear, size: shape.size)
        let glyph = Glyph(image: image)!
        self.init(shape: shape, shapeColor: shapeColor,
                  border: border, glyph: glyph,
                  glyphTintColor: .clear, padding: padding)
    }

    public func makeImage() -> UIImage {
        let scaledGlyph: Glyph
        if let border = border, border.glyphScaling == .considerBorder {
            scaledGlyph = glyph.scaled(to: glyph.size - .square(border.width * 2))
        } else {
            scaledGlyph = glyph
        }
        let tintedImage = scaledGlyph.image.tinted(with: glyphTintColor)
        /// Return glyph with tint and padding if dont have shape.
        guard let shape = shape else { return tintedImage.padding(with: paddingInsets) }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return tintedImage.padding(with: paddingInsets) }
        context.saveGState()
        shapeColor.setFill()

        let path = shape.path(with: paddingInsets, borderWidth: border?.width ?? 0)
        path.fill()

        if let border = border, border.glyphScaling == .considerBorder {
            drawGlyph(considering: border.width)
        } else {
            drawGlyph()
        }

        func drawGlyph(considering borderWidth: CGFloat = 0) {
            let size = shape.size - glyph.size
            tintedImage.draw(at: .init(x: size.width / 2 + borderWidth + paddingInsets.left,
                                       y: size.height / 2 + borderWidth + paddingInsets.top))
        }

        if let border = border {
            path.lineWidth = border.width
            border.color.setStroke()
            path.stroke()
        }

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return tintedImage }
        context.restoreGState()
        UIGraphicsEndImageContext()
        /// Creating new context for masking. If dont, masking works incorrectly.
        return image.mask(path: path)
    }
}

// MARK: Setters
public extension IconModel {

    func color(_ newValue: UIColor) -> Self {
        updated(\.glyphTintColor, with: newValue)
    }

    func shape(_ newValue: Shape?) -> Self {
        updated(\.shape, with: newValue)
    }

    func shapeColor(_ newValue: UIColor) -> Self {
        updated(\.shapeColor, with: newValue)
    }

    func padding(_ newValue: UIEdgeInsets) -> Self {
        updated(\.paddingInsets, with: newValue)
    }

    func shapeSize(_ newValue: CGSize) -> Self {
        guard shape?.size != newValue else { return self }
        return updated { $0.shape?.size = newValue }
    }

    func glyphSize(_ newValue: CGSize) -> Self {
        guard glyph.size != newValue else { return self }
        return updated(\.glyph, with: glyph.scaled(to: newValue))
    }

    func setBorder(_ newValue: Border?) -> Self {
        updated(\.border, with: newValue)
    }

    /// Scaling (down) a glyph so it perfectly fits the shape. Usually used for downloaded FIIcons.
    func scaledToShape() -> Self {
        guard let shapeSize = shape?.size else { return self }
        return glyphSize(shapeSize)
    }
}

public extension IconModel {
    /// text: text to draw on icon (e.g. currency symbol icons in currency selector)
    /// textStyle: textStyle for text (font size will be smaller, if text won't fit the icon size with 'textStyle' font!)
    static func fromText(_ text: String,
                         textStyle: TextStyle,
                         shape: Shape,
                         shapeColor: UIColor,
                         border: Border? = nil,
                         glyphTintColor: UIColor? = nil) -> IconModel? {
        let rect = shape.size.rect
        let fittingFontSize = min(textStyle.fontSizeValue,
                                  UIFont.bestFittingFontSize(for: text,
                                                             in: rect,
                                                             fontDescriptor: textStyle.font.fontDescriptor))
        let fittingStyle = textStyle.fontSize(fittingFontSize).lineHeight(textStyle.font.lineHeight)
        let attrText = text.style(fittingStyle)

        let textSize = attrText.boundingRect(with: rect.size,
                                             options: .usesLineFragmentOrigin,
                                             context: nil).size

        UIGraphicsBeginImageContextWithOptions(textSize, false, UIScreen.main.scale)
        (text as NSString).draw(in: rect, withAttributes: fittingStyle.attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let glyph = Glyph(image: image) else { return nil }
        return IconModel(shape: shape, shapeColor: shapeColor, border: border, glyph: glyph, glyphTintColor: glyphTintColor)
    }
}
