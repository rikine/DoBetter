//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

struct TableStopperViewModel {

    static let titleStyle: TextStyle = .subtitle.multiline.center.semibold.lineHeight(25)
    static let subtitleStyle: TextStyle = .line.multiline.center.secondary.lineHeight(22)

    let image: IconModel?
    var title: NSAttributedString?
    var subtitle: NSAttributedString?
    let background: UIColor
    let buttonBarModel: ButtonBarStack.Model?
    var stickedToTop: Bool
    let cornerRadius: CGFloat
    var stopperPadding: UIEdgeInsets
    let imageSize: CGSize?
    let imageContentMode: UIView.ContentMode?

    init(image: IconModel? = nil,
         title: StopperPlaceholder.Title? = nil,
         subtitle: StopperPlaceholder.Subtitle? = nil,
         background: UIColor = .background2,
         buttonBarModel: ButtonBarStack.Model? = nil,
         stickedToTop: Bool = true,
         cornerRadius: CGFloat = 0,
         stopperPadding: UIEdgeInsets = .zero,
         imageSize: CGSize? = nil,
         imageContentMode: UIView.ContentMode? = nil) {
        self.init(image: image,
                  title: title?.rawValue,
                  subtitle: subtitle?.rawValue,
                  background: background,
                  buttonBarModel: buttonBarModel,
                  stickedToTop: stickedToTop,
                  cornerRadius: cornerRadius,
                  stopperPadding: stopperPadding,
                  imageSize: imageSize,
                  imageContentMode: imageContentMode)
    }

    init(_ placeholder: StopperPlaceholder,
         background: UIColor = .background2,
         buttonBarModel: ButtonBarStack.Model? = nil,
         stickedToTop: Bool = true,
         cornerRadius: CGFloat = 0,
         stopperPadding: UIEdgeInsets = .zero,
         imageSize: CGSize? = nil,
         imageContentMode: UIView.ContentMode? = nil) {
        self.init(image: placeholder.image,
                  title: placeholder.title,
                  subtitle: placeholder.subtitle,
                  background: background,
                  buttonBarModel: buttonBarModel,
                  stickedToTop: stickedToTop,
                  cornerRadius: cornerRadius,
                  stopperPadding: stopperPadding,
                  imageSize: imageSize,
                  imageContentMode: imageContentMode)
    }

    @available(*, deprecated, message: "Use init above")
    init(image: IconModel? = nil,
         title: String? = nil,
         subtitle: String? = nil,
         background: UIColor = .background2,
         buttonBarModel: ButtonBarStack.Model? = nil,
         stickedToTop: Bool = true,
         cornerRadius: CGFloat = 0,
         stopperPadding: UIEdgeInsets = .zero,
         imageSize: CGSize? = nil,
         imageContentMode: UIView.ContentMode? = nil) {
        self.image = image
        self.title = title?.style(Self.titleStyle)
        self.subtitle = subtitle?.style(Self.subtitleStyle)
        self.background = background
        self.stickedToTop = stickedToTop
        self.cornerRadius = cornerRadius
        self.stopperPadding = stopperPadding
        self.imageSize = imageSize
        self.imageContentMode = imageContentMode
        self.buttonBarModel = buttonBarModel
    }
}

extension TableStopperViewModel: ViewModel, CellViewModel, EquatableCellViewModel, Equatable {

    func setup(view: TableStopper) {
        view.title.textOrHidden(title)
        view.subtitle.textOrHidden(subtitle)
        view.wrapperStack.background(color: background)
        view.image?.icon(image)
        view.image?.hidden(image == nil)
        imageSize.let { view.image?.size($0) } ?? view.image?.size(.compact)
        view.image?.contentMode(imageContentMode ?? .scaleToFill)
        view.contentStack.spacing(16)
        view.wrapperStack.corner(radius: cornerRadius)
        view.padding(stopperPadding)

        // Prevents visually jumping when two screen in tabbed controller have placeholder with images
        // For screens used both as tab and independently set manually `stickedToTop`
        if image == nil || !stickedToTop {
            view.contentStack.position(.center)
        } else {
            view.padding(.top(UIScreen.main.bounds.height * (0.1)))
        }

        if let buttonBarModel = buttonBarModel {
            buttonBarModel.setup(view: view.buttonBar)
            view.buttonBar.hidden(false)
        } else {
            view.buttonBar.hidden(true)
        }
    }

    func setup(cell: TableStopperCell) {
        setup(view: cell.stopperView)
    }
}

extension TableStopperViewModel: Updatable {
    static let sorryPlaceholder = TableStopperViewModel(.sorry, background: .clear)

    static let ownTasksPlaceholder = TableStopperViewModel(image: .Task.empty,
                                                           title: .emptyOwnTasks,
                                                           subtitle: .emptyOwnTasks,
                                                           background: .clear,
                                                           buttonBarModel: nil,
                                                           stickedToTop: false,
                                                           cornerRadius: 8,
                                                           stopperPadding: .zero,
                                                           imageSize: .square(244),
                                                           imageContentMode: .scaleAspectFit)

    static let otherTasksPlaceholder = TableStopperViewModel(image: .Task.empty,
                                                             title: .emptyFollowingsTasks,
                                                             subtitle: .emptyFollowingsTasks,
                                                             background: .clear,
                                                             buttonBarModel: nil,
                                                             stickedToTop: false,
                                                             cornerRadius: 8,
                                                             stopperPadding: .zero,
                                                             imageSize: .square(244),
                                                             imageContentMode: .scaleAspectFit)

    static let otherTasksPlaceholderNotCurrent = TableStopperViewModel(image: .Task.empty,
                                                                       title: .emptyOtherTasks,
                                                                       background: .clear,
                                                                       buttonBarModel: nil,
                                                                       stickedToTop: false,
                                                                       cornerRadius: 8,
                                                                       stopperPadding: .zero,
                                                                       imageSize: .square(244),
                                                                       imageContentMode: .scaleAspectFit)

    func stickedToTop(_ newValue: Bool) -> Self {
        updated(\.stickedToTop, with: newValue)
    }

    func title(_ newValue: AttrString) -> Self {
        updated(\.title, with: newValue.apply(textStyle: Self.titleStyle).interpolated())
    }

    func title(_ newValue: String) -> Self {
        title(newValue.attrString)
    }

    func subtitle(_ newValue: AttrString) -> Self {
        updated(\.subtitle, with: newValue.apply(textStyle: Self.subtitleStyle).interpolated())
    }

    func subtitle(_ newValue: String) -> Self {
        subtitle(newValue.attrString)
    }
}
