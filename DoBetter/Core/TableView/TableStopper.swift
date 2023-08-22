//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import ViewNodes
import UIKit

final class TableStopper: InitializableView {
    var wrapperStack: ZStack!
    var contentStack: VStack!
    var image: Image?
    var title: Text!
    var subtitle: Text!
    var buttonBar: ButtonBarStack!

    override init() {
        super.init()
        config(backgroundColor: .clear)
        content {
            wrapperStack = ZStack()
                    .width(.fill)
                    .content {
                        contentStack = VStack()
                                .padding(.horizontal(32))
                                .width(.fill)
                                .content {
                                    VStack().alignment(.center).padding(.bottom(16)).content {
                                        image = Image()
                                    }
                                    title = Text().width(.fill)
                                    subtitle = Text().width(.fill)
                                }
                        buttonBar = ButtonBarStack(.vertical).position(.bottom)
                    }
        }
    }
}

class TableStopperCell: ViewNodeCell {
    var stopperView: TableStopper!

    override func makeView() -> View {
        stopperView = TableStopper()
        return stopperView
    }
}
