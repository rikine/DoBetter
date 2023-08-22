//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit
import ViewNodes

class ViewNodeCell: UITableViewCell {
    private(set) lazy var container = makeContainer()
    var view: View!

    public override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(container)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
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

    open override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                               withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                               verticalFittingPriority: UILayoutPriority) -> CGSize {
        container.sizeThatFits(targetSize)
    }

    open override func layoutSubviews() {
        container.frame = bounds
        container.layoutSubviewsRecursively()
        super.layoutSubviews()
    }
}
