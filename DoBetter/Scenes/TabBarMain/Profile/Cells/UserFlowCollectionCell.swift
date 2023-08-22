//
// Created by Никита Шестаков on 22.03.2023.
//

import Foundation
import ViewNodes

class UserFlowView: VStack, Initializable {
    private(set) var image: Image!
    private(set) var nickname: Text!

    required override init() {
        super.init()

        padding(.vertical(8))
        config(backgroundColor: .clear)
        spacing(8)
        corner(radius: 8)
        content {
            image = Image().size(56)
            nickname = Text().lines(2)
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, PayloadableCellModel {
        let icon: DownloadableIconModel
        let nickname: AttrString

        var payload: CellModelPayload?

        var size: CGSize {
            let string = nickname.apply(.label.lines(2).center.foreground).interpolated()
            let lineHeight = (string.lineHeight() ?? .zero) * 2 + 1
            let rect = string.boundingRect(with: .init(width: 100, height: lineHeight))

            return .init(width: max(min(rect.width, 100), 56 + 16), height: min(rect.height, lineHeight) + 8 * 3 + 56)
        }

        func setup(view: UserFlowView) {
            view.image.image(icon)
            view.nickname.text(nickname.apply(.label.lines(2).center.foreground))
        }

        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.icon == rhs.icon && lhs.nickname == rhs.nickname && lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }
    }
}

extension UserFlowView {
    class CollectionCell: ViewNodeCollectionCellByView<UserFlowView> {
        typealias Model = CollectionCellViewModelByView<UserFlowView.Model, CollectionCell>
    }

    typealias CollectionFlow = FlowCollectionCellModel<CollectionCell.Model>
}
