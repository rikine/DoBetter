//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import UIKit
import ViewNodes

class SearchUserView: HStack, Initializable {
    private(set) var image: Image!
    private(set) var title: Text!
    private(set) var subtitle: Text!
    private(set) var button: RoundCornersButton!

    required override init() {
        super.init()

        config(backgroundColor: .clear)
        spacing(8)
        padding(.all(12))
        width(.fill)
        alignment(.center)
        content {
            image = Image().size(40)

            VStack().spacing(4).width(.fill).content {
                title = Text()
                subtitle = Text().lines(4)
            }

            VStack().alignment(.center).content {
                HStack().alignment(.middle).content {
                    button = RoundCornersButton()
                }
            }
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, UpdatableWithoutReloadingRow, PayloadableCellModel {
        let image: DownloadableIconModel
        let title: String
        let subtitle: String?
        let button: RoundCornersButton.Model?

        var payload: CellModelPayload?

        func setup(view: SearchUserView) {
            view.image.image(image)
            view.title.text(title.apply(style: .line))
            view.subtitle.text(subtitle?.apply(style: .line.secondary))

            button?.setup(view: view.button)
            view.button.hidden(button == nil)
        }

        static func ==(lhs: SearchUserView.Model, rhs: SearchUserView.Model) -> Bool {
            lhs.image == rhs.image && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
                && lhs.button == rhs.button && lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }

        static let empty = Model(image: .init(url: nil, placeholder: .init(shape: .squircle, shapeColor: .accent)),
                                 title: ".............",
                                 subtitle: ".......................", button: nil)
    }
}

extension SearchUserView {
    class Cell: ViewNodeCellByView<SearchUserView> {
        typealias Model = CellViewModelByView<SearchUserView.Model, Cell>
    }
}

extension SearchUserView.Cell.Model {
    static let empty = SearchUserView.Cell.Model(SearchUserView.Model.empty)
}
