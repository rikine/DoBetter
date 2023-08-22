//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation
import ViewNodes

class UploadImageView: ZStack, Initializable {
    private(set) var image: Image!
    private(set) var info: Text!
    private(set) var remove: Text!

    required override init() {
        super.init()

        config(backgroundColor: .clear)
        padding(.vertical(8))
        content {
            VStack().content {
                image = Image().padding(.all(16)).size(80)
                info = Text(Localization.imageUpload.localized.apply(style: .label.multiline.center.accent).interpolated())
                        .padding(.top(8))
                remove = Text(Localization.deleteImage.localized.apply(style: .label.multiline.center.color(.destructive)).interpolated())
                        .padding(.top(8))
            }.position(.center)
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, UpdatableWithoutReloadingRow {
        let image: DownloadableIconModel

        func setup(view: UploadImageView) {
            view.image.image(image)
        }
    }
}

extension UploadImageView {
    class Cell: ViewNodeCellByView<UploadImageView> {
        typealias Model = CellViewModelByView<UploadImageView.Model, Cell>
    }
}
