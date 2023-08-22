//
// Created by Никита Шестаков on 11.03.2023.
//

import Foundation
import ViewNodes
import UIKit

extension BottomSheetHeadlineView {
    class Cell: ViewNodeCellByView<BottomSheetHeadlineView> {
        typealias Model = CellViewModelByView<BottomSheetHeadlineView.Model, Cell>
    }
}

final class BottomSheetHeadlineView: HStack, Initializable {
    var headline: Text!
    var caption: Text!
    var rightText: Text!

    override init() {
        super.init()
        config(backgroundColor: .clear)
        spacing(16)
        padding(.top(20))
        content {
            VStack()
                    .width(.fill)
                    .spacing(4)
                    .content {
                        headline = Text().width(.fill)
                        caption = Text().width(.fill).padding(.bottom(3))
                    }
            rightText = Text()
        }
    }
}

extension BottomSheetHeadlineView {
    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let headline: AttrString?
        let caption: AttrString?
        let padding: UIEdgeInsets
        let rightText: AttrString?

        init(headline: AttrString? = nil, caption: AttrString? = nil, rightText: AttrString? = nil,
             padding: UIEdgeInsets = .horizontal(16) + .vertical(12) + .top(12)) { // .top(12) для отступа от полоски селектора {
            self.headline = headline.apply(textStyle: .subtitle.bold.multiline)
            self.caption = caption.apply(textStyle: .line.multiline.secondary)
            self.padding = padding
            self.rightText = rightText
        }

        func setup(view: BottomSheetHeadlineView) {
            view.headline.textOrHidden(headline.interpolated())
            view.headline.padding(caption == nil ? .top(8) + .bottom(7) : .top(4))

            view.caption.textOrHidden(caption?.interpolated())
            view.rightText.textOrHidden(rightText)

            view.padding(padding)
        }
    }
}
