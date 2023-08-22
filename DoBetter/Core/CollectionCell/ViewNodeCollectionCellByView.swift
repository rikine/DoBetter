//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import ViewNodes

class ViewNodeCollectionCellByView<MainView: InitializableView>: ViewNodeCollectionCell {
    public var wrapperView: View!
    public var mainView: MainView!

    override func makeView() -> View {
        wrapperView = View().background(color: .clear).content {
            mainView = MainView()
        }
        return wrapperView
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        mainView.prepareForReuse()
    }
}
