//
// Created by Никита Шестаков on 20.02.2023.
//

import UIKit

public class IconAttachment: NSTextAttachment {

    public let iconModel: IconModel

    public init(iconModel: IconModel, capHeight: CGFloat?) {
        self.iconModel = iconModel
        super.init(data: nil, ofType: nil)
        image = iconModel.makeImage()
        let y: CGFloat
        if let capHeight = capHeight {
            y = (capHeight - iconModel.size.height) / 2
        } else {
            y = 0
        }
        bounds = CGRect(x: 0,
                        y: y,
                        width: iconModel.size.width,
                        height: iconModel.size.height)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
