//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit
import ViewNodes

class ViewNodeCollectionCell: UICollectionViewCell {
    private(set) lazy var container = makeContainer()
    var view: View!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(container)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeView() -> View {
        View()
    }

    private func makeContainer() -> View {
        HStack()
            .background(color: .clear)
            .content {
                view = makeView()
                    .width(.fill)
            }
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        container.sizeThatFits(targetSize)
    }

    override func layoutSubviews() {
        container.frame = bounds
        container.layoutSubviewsRecursively()
        super.layoutSubviews()
    }
}
