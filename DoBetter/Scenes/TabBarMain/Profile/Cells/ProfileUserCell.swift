//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import ViewNodes

class ProfileUserView: ZStack, Initializable {
    private(set) var image: Image!
    private(set) var name: Text!
    private(set) var nickname: Text!
    private(set) var button: RoundCornersButton!

    required override init() {
        super.init()

        config(backgroundColor: .clear)
        padding(.all(16))
        content {
            VStack().size(.fill).position(.bottom).content {
                View().height(32)
                View().background(color: .content2).size(.fill).corner(radius: 12)
            }

            VStack().position(.top).spacing(8).content {
                image = Image().size(.square(80))

                VStack().spacing(4).content {
                    name = Text()
                    nickname = Text()
                }

                VStack().alignment(.center).padding(.bottom(16)).content {
                    HStack().alignment(.middle).content {
                        button = RoundCornersButton()
                    }
                }
            }
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let icon: DownloadableIconModel
        let nickname: String
        let name: String?

        let button: RoundCornersButton.Model?

        func setup(view: ProfileUserView) {
            view.image.image(icon)
            view.nickname.text(nickname.apply(style: .label.multiline.secondary.center))
            view.name.textOrHidden(name?.apply(style: .label.multiline.center.foreground))

            button?.setup(view: view.button)
            view.button.hidden(button == nil)
        }
    }
}

extension ProfileUserView {
    class Cell: ViewNodeCellByView<ProfileUserView> {
        typealias Model = CellViewModelByView<ProfileUserView.Model, Cell>
    }
}
