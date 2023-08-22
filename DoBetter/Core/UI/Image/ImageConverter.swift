//
//  ImageConverter.swift
//  VisionInvestUI
//
//  Created by Вадим Серегин on 24.10.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import Foundation
import AVFoundation.AVUtilities

public struct ImageConverter: Equatable, Updatable {

    public enum ShapeAspectMode {
        /// Just convert image to given shape
        case `default`

        /// Makes ImageConverter.shape to apply aspect ratio of downloaded image (as aspectRatio: CGSize)
        /// Shape can become smaller on one axis or stay the same
        /// Use if result image is flattened or something like this and u don't that behaviour
        /// If image is smaller, you can just use contentMode(.scaleAspectFill) and it won't be flattened but zoomed
        case saveAspectRatio
    }

    public var name: String
    public let size: CGSize
    public let alpha: Float
    public let shape: IconModel.Shape?
    public let border: IconModel.Border?
    public let shapeAspectMode: ShapeAspectMode

    public init(name: String,
                size: CGSize,
                alpha: Float = 1.0,
                shape: IconModel.Shape? = nil,
                border: IconModel.Border? = nil,
                shapeAspectMode: ShapeAspectMode = .saveAspectRatio) {
        self.name = name
        self.size = size
        self.alpha = alpha
        self.shape = shape
        self.border = border
        self.shapeAspectMode = shapeAspectMode
    }

    /// - Parameter aspectRatio: Needed aspectRatio for shape
    /// - Returns: if ShapeAspectMode is default, just return shape. If saveAspectRatio, return shape with given aspectRatio
    public func convertShape(to aspectRatio: CGSize) -> IconModel.Shape? {
        guard let shape = shape else { return nil }

        switch shapeAspectMode {
        case .default: return shape
        case .saveAspectRatio:
            let resultSize = AVMakeRect(aspectRatio: aspectRatio, insideRect: shape.size.rect).size
            return .init(size: resultSize, smoothing: shape.smoothing)
        }
    }

    public func name(_ newValue: String) -> Self {
        updated(\.name, with: newValue)
    }
}
