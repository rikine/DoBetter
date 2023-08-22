//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension IconModel {
    func makeDisabledIfNeeded(with model: DisabledModel?) -> Self {
        model?.makeDisabled(self) ?? self
    }
}

public extension IconModel {
    /// Недоступная иконка, передается в Image
    /// Если присутствует, то заменяет иконку с параметрами ниже
    /// Для картинок из инета: ПОЛНОСТЬЮ окрашивает их в glyphColor (так быть не должно, надо думоть)
    struct DisabledModel: Equatable {
        private(set) public var border: Border?
        private(set) public var shapeColor: UIColor?
        private(set) public var glyphColor: UIColor

        public init(shapeColor: UIColor? = .content2, glyphColor: UIColor = .foreground3, border: Border? = nil) {
            self.shapeColor = shapeColor
            self.glyphColor = glyphColor
            self.border = border
        }

        public func makeDisabled(_ iconModel: IconModel) -> IconModel {
            iconModel.color(glyphColor).setBorder(border).shapeColor(shapeColor ?? .clear)
        }
    }
}

extension IconModel.DisabledModel {
    public static let `default` = IconModel.DisabledModel()
}
