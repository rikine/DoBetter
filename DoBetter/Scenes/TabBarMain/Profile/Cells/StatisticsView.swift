//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import ViewNodes

class InnerStatisticsView: VStack, Initializable {
    private(set) var number: Text!
    private(set) var caption: Text!

    required override init() {
        super.init()

        config(backgroundColor: .clear)
        width(.fill)
        spacing(8)
        alignment(.center)
        content {
            number = Text()
            caption = Text()
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let number: AttrString
        let caption: AttrString

        func setup(view: InnerStatisticsView) {
            view.number.text(number.apply(.subtitle.multiline.center))
            view.caption.text(caption.apply(.label.multiline.center))
        }
    }
}

class StatisticsView: VStack, Initializable {
    private(set) var statistics: HStackOf<InnerStatisticsView>!

    required override init() {
        super.init()

        width(.fill)
        spacing(8)
        config(backgroundColor: .clear)
        content {
            statistics = HStackOf<InnerStatisticsView>(view: InnerStatisticsView())
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let statistics: [InnerStatisticsView.Model]

        func setup(view: StatisticsView) {
            view.statistics.update(with: statistics)
        }
    }
}

extension StatisticsView {
    class Cell: ViewNodeCellByView<StatisticsView> {
        typealias Model = CellViewModelByView<StatisticsView.Model, Cell>
    }
}