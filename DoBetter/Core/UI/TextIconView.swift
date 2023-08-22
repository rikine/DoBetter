//
// Created by Никита Шестаков on 15.04.2023.
//

import Foundation
import ViewNodes
import UIKit

/// Общая вьюха для ячеек типа иконка + текст + подтекст
class TextIconView: HStack, Initializable {
    private(set) var imageWithBadge: ImageWithBadge!
    private(set) var textStack: VStack!
    private(set) var title: Text!
    private(set) var caption: Text!

    override required init() {
        super.init()
        content {
            imageWithBadge = ImageWithBadge()

            HStack()
                    .width(.fill)
                    .alignment(.center)
                    .content {
                        textStack = VStack()
                                .width(.fill)
                                .spacing(4)
                                .content {
                                    title = Text().lines(2)
                                    caption = Text().lines(2)
                                }
                    }
        }
    }

    struct Model: ViewModel, Equatable {
        typealias Icon = ImageWithBadge.Model

        let title: NSAttributedString
        let caption: NSAttributedString?
        let icon: Icon?

        init(title: AttrString, caption: AttrString? = nil, icon: Icon? = nil) {
            self.init(title: title.interpolated(), caption: caption.interpolated(), icon: icon)
        }

        init(title: NSAttributedString, caption: NSAttributedString? = nil, icon: Icon? = nil) {
            self.title = title
            self.caption = caption
            self.icon = icon
        }

        func setup(view: TextIconView) {
            icon?.setup(view: view.imageWithBadge)
            view.imageWithBadge.hidden(icon == nil)

            view.title.text(title)
            view.caption.textOrHidden(caption)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageWithBadge.icon.prepareForReuse()
    }
}

extension TextIconView {
    class Cell: ViewNodeCellByView<TextIconView> {
        typealias Model = CellViewModelByView<TextIconView.Model, Cell>
    }
}
