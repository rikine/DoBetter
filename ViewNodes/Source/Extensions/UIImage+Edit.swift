//
// Created by Maxime Tenth on 10/31/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

public extension UIImage {
    func tinted(with color: UIColor?) -> UIImage {
        guard let color = color else { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        context.fill(rect)

        let newImage: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    func mask(path: UIBezierPath) -> UIImage {
        edit { context in
            path.addClip()
            context.addPath(path.cgPath)
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
    }

    func stroke(path: UIBezierPath, color: UIColor, width: CGFloat) -> UIImage {
        edit { context in
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            context.addPath(path.cgPath)
            context.setLineWidth(width)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
    }

    func padding(with insets: UIEdgeInsets) -> UIImage {
        edit(targetSize: size + insets.size) { _ in
            draw(in: CGRect(x: insets.left,
                            y: insets.top,
                            width: size.width,
                            height: size.height))
        }
    }

    func scale(to targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: targetSize))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }

    func edit(targetSize: CGSize? = nil, _ body: (CGContext) -> Void ) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize ?? size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.saveGState()

        body(context)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        context.restoreGState()
        UIGraphicsEndImageContext()
        return image
    }

    static func from(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.saveGState()
        context.setFillColor(color.cgColor)
        context.fill(size.rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        context.restoreGState()
        UIGraphicsEndImageContext()
        return image
    }

    func alpha(_ value: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
