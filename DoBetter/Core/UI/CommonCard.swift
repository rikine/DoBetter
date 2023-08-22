//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import ViewNodes
import UIKit

class CommonCard: View, Initializable {
    required override init() {
        super.init()
        _setup()
    }

    private func _setup() {
        corner(radius: 12)
        padding(.all(16))
    }

    open override func background(color: UIColor) -> Self {
        super.background(.layer(color))
    }
}
