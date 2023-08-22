//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import UIKit

public extension UIImageAsset {
    func image(with userInterfaceStyle: UIUserInterfaceStyle) -> UIImage {
        image(with: .init(traitsFrom: [.current, .init(userInterfaceStyle: userInterfaceStyle)]))
    }
}
