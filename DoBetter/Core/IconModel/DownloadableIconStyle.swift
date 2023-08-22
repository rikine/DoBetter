//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import ViewNodes
import UIKit

public enum DownloadableIconStyle: Equatable {
    public enum ShapeStyle {
        case common, mini, big, list, bordered, button, large
        case commonUnavailable
    }

    case squircle(ShapeStyle)
    case circle(ShapeStyle)

    /// FIXME: Временное решение, поменять везде на .squircle(...) и убрать
    public static let common = Self.squircle(.common)
    public static let mini = Self.squircle(.mini)
    public static let big = Self.squircle(.big)
    public static let list = Self.squircle(.list)
    public static let bordered = Self.squircle(.bordered)
    public static let button = Self.squircle(.button)
    public static let large = Self.squircle(.large)
    public static let commonUnavailable = Self.squircle(.commonUnavailable)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case  (.squircle(let lhsShape), .squircle(let rhsShape)):
            return lhsShape == rhsShape
        case (.circle(let lhsShape), .circle(let rhsShape)):
            return lhsShape == rhsShape
        default:
            return false
        }
    }
}

public extension DownloadableIconStyle {

    static let commonSize = CGSize.square(40)
    static let listSize = CGSize.square(56)
    static let miniSize = CGSize.square(20)
    static let largeSize = CGSize.square(80)
    static let buttonSize = CGSize.square(28)

    var size: CGSize {
        switch self {
        case .squircle(let shape), .circle(let shape):
            switch shape {
            case .common, .commonUnavailable:
                return Self.commonSize
            case .bordered:
                return Self.commonSize
            case .list:
                return Self.listSize
            case .mini:
                return Self.miniSize
            case .big:
                return Self.listSize
            case .button:
                return Self.buttonSize
            case .large:
                return Self.largeSize
            }
        }
    }

    var sizeWithBorder: CGSize {
        let borderWidth = border?.width ?? 0
        return size + .square(borderWidth * 2)
    }

    var shape: IconModel.Shape {
        switch self {
        case .circle: return .circleOf(size: sizeWithBorder)
        case .squircle: return .squircleOf(size: sizeWithBorder)
        }
    }

    private var border: IconModel.Border? { nil }

    private var alpha: Float {
        switch self {
        case .squircle(.commonUnavailable), .circle(.commonUnavailable): return 0.2
        default: return 1.0
        }
    }

    var process: ImageConverter {
        .init(name: String(describing: self), size: sizeWithBorder, alpha: alpha, shape: shape, border: border)
    }

    func process(shape: IconModel.Shape) -> ImageConverter {
        ImageConverter(name: String(describing: self), size: shape.size, alpha: alpha, shape: shape, border: border)
    }

    var emptyPlaceholder: IconModel {
        placeholder(shapeColor: .background)
    }

    func placeholder(shapeColor: UIColor, glyph: Glyph? = nil, glyphTintColor: UIColor = .clear) -> IconModel {
        IconModel(shape: shape, shapeColor: shapeColor, border: border,
                  glyph: glyph ?? .empty(ofSize: shape.size),
                  glyphTintColor: glyphTintColor)
    }
}
