//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation
import UIKit

class RefreshControl: UIRefreshControl {

    enum RefreshControlStyle {
        case white, none

        var image: UIImage? {
            switch self {
            case .white:
                return UIImage.ActivityIndication.whiteSpiner
            case .none:
                return nil
            }
        }
    }

    var offset: CGFloat = 0
    var style: RefreshControlStyle = .white
    var padding: CGFloat = 8
    let imgSize: CGFloat = UIImage.ActivityIndication.medium.height

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: style.image)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.frame = .zero
        addSubview(imageView)
        return imageView
    }()

    init(style: RefreshControlStyle) {
        self.style = style
        super.init()
        backgroundColor = .clear
        tintColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var frame: CGRect {
        get { super.frame }

        set {
            var rect = newValue
            rect.origin.y += offset
            super.frame = rect

            let size = CGSize(width: rect.size.width - padding * 2,
                              height: (rect.size.height - padding * 2).clamped(nil, imgSize))
            imageView.frame = CGRect(origin: CGPoint(x: padding, y: padding), size: size)
        }
    }
}
