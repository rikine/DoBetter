//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension UIImage {

    var dominantColor: UIColor {
        pixelColor(at: .init(x: size.width / 4, y: 0)) ?? .black
    }

    /// https://stackoverflow.com/a/64522645
    func pixelColor(at position: CGPoint) -> UIColor? {
        guard let cgImage = _srgbCGImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data
        else { return nil }

        let pixelData: UnsafePointer<UInt8> = CFDataGetBytePtr(data)

        // Calculate the pixel position based on point given
        let remaining = 8 - ((Int(size.width)) % 8)
        let padding = (remaining < 8) ? remaining : 0
        let pixelInfo: Int = (((Int(size.width) + padding) * Int(position.y)) + Int(position.x)) * 4

        let rgba = (pixelInfo...pixelInfo+3).map { CGFloat(pixelData[$0]) / 255.0 }

        return UIColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    }

    // Converte image to srgb
    /// https://stackoverflow.com/a/64548699
    private var _srgbCGImage: CGImage? {
        guard let cgImage = cgImage,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        return context.makeImage()
    }

    func imageWithInset(insets: UIEdgeInsets) -> UIImage? {

        let size = CGSize(width: self.size.width + insets.left + insets.right,
                          height: self.size.height + insets.top + insets.bottom)

        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        return imageWithInsets
    }
}
