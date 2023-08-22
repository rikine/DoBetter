//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

public protocol AnyIconModel: AnyEquatable {
    func setupIcon(_ icon: Image)
}

extension Optional where Wrapped == AnyIconModel {
    public func setupOrHideIcon(_ icon: Image) {
        icon.hidden(self == nil)
        self.let { $0.setupIcon(icon) }
    }
}

extension IconModel: AnyIconModel {
    public func setupIcon(_ icon: Image) {
        icon.icon(self)
    }
}
