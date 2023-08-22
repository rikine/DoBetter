//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import ViewNodes
import UIKit

class ImageWithBadge: ZStack, Initializable {

    static var iconSize: CGSize = .square(40)

    var icon: Image!

    override required init() {
        super.init()
        content {
            icon = Image()
                .contentMode(.bottom)
        }
    }

    private func addBadges(_ badges: [View.Position: IconModel?]) {
        guard icon != nil else { return }
        for (position, icon) in badges {
            guard let icon = icon else { return }
            let badgeIcon = Image().background(color: .clear).icon(icon).position(position)
            addSubnode(badgeIcon)
        }
    }

    struct Model: Equatable {
        let iconModel: AnyIconModel?
        let badges: [View.Position: IconModel?]
        let mainIconPadding: UIEdgeInsets
        let iconSize: CGSize
        let contentMode: UIView.ContentMode

        var fullSize: CGSize { iconSize + mainIconPadding }

        init(iconModel: AnyIconModel?,
             badges: [View.Position: IconModel?] = [:],
             mainIconPadding: UIEdgeInsets = .all(8),
             iconSize: CGSize = IconModel.Shape.regularSize,
             contentMode: UIView.ContentMode = .bottom) {
            self.iconModel = iconModel
            self.badges = badges
            self.mainIconPadding = mainIconPadding
            self.iconSize = iconSize
            self.contentMode = contentMode
        }

        func setup(view: ImageWithBadge) {
            if let fiIcon = iconModel as? DownloadableIconModel {
                view.icon.image(fiIcon, converter: fiIcon.convert)
            } else {
                iconModel?.setupIcon(view.icon)
            }
            view.removeSubviews()
            view.addSubnode(view.icon)
            view.icon.size(fullSize).padding(mainIconPadding).contentMode(contentMode)
            view.addBadges(badges)
        }

        static func ==(lhs: Model, rhs: Model) -> Bool {
            (lhs.iconModel?.isEqual(to: rhs.iconModel) ?? false)
                && lhs.badges == rhs.badges
                && lhs.mainIconPadding == rhs.mainIconPadding
                && lhs.iconSize == rhs.iconSize
        }
    }
}
