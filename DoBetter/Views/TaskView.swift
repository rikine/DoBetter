//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import ViewNodes
import UIKit

class TaskView: VStack, Initializable {
    private(set) var doneButton: RoundCornersButton!
    private(set) var likeButton: RoundCornersButton!
    private(set) var title: Text!
    private(set) var image: Image!
    private(set) var descriptionText: Text!
    private(set) var endDate: Text!
    private(set) var name: Text!
    private(set) var separator: View!

    required override init() {
        super.init()

        config(backgroundColor: .clear)
        corner(radius: 12)
        padding(.all(8))
        width(.fill)
        content {
            HStack().alignment(.center).width(.fill).content {
                VStack().width(.fill).spacing(4).content {
                    HStack().alignment(.center).spacing(12).content {
                        image = Image().size(56)

                        VStack().spacing(4).content {
                            title = Text()
                            descriptionText = Text()
                        }
                    }

                    endDate = Text()
                }

                HStack().height(.fill).content {
                    VStack().height(.fill).spacing(8).content {
                        doneButton = RoundCornersButton().size(24).corner(radius: 8).border(color: .foreground)
                        likeButton = RoundCornersButton().size(24).corner(radius: 8)
                    }
                }
            }

            View().width(.fill).padding(.right(24 + 8)).content {
                separator = View().height(1).background(color: .foreground4)
            }

            name = Text().multiline()
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel, PayloadableCellModel {
        let title: AttrString
        let image: DownloadableIconModel?
        let description: AttrString?
        let endDate: AttrString?
        let color: UIColor
        let isDone: Bool
        let isDoneLoading: Bool
        let isLiked: Bool
        let isLikeLoading: Bool
        let name: AttrString?
        let isInProgress: Bool

        var payload: CellModelPayload?

        static let empty = Model(title: "........", image: nil, description: nil, endDate: nil, color: .clear, isDone: false,
                                 isDoneLoading: false, isLiked: false, isLikeLoading: false, name: nil, isInProgress: false, payload: nil)

        func setup(view: TaskView) {
            view.title.text(title.apply(.line.multiline.foreground))
            view.image.image(image).hidden(image == nil)
            view.descriptionText.textOrHidden(description?.apply(.label.multiline.foreground))
            view.endDate.textOrHidden(endDate.apply(textStyle: .detail.secondary.multiline))
            view.background(color: color)

            view.separator.hidden(name == nil)
            view.name.textOrHidden(name?.apply(.label.secondary))

            RoundCornersButton.Model(text: nil,
                                     iconModel: isInProgress ? .Task.progress : (isDone ? .Task.tick : nil),
                                     style: .text,
                                     isEnabled: !isDoneLoading,
                                     isLoading: isDoneLoading,
                                     height: 24,
                                     width: 24)
                    .setup(view: view.doneButton)

            RoundCornersButton.Model(text: nil,
                                     iconModel: isLiked ? .Task.heartFill : .Task.heart,
                                     style: .text,
                                     isEnabled: !isLikeLoading,
                                     isLoading: isLikeLoading,
                                     height: 24,
                                     width: 24)
                    .setup(view: view.likeButton)
        }

        static func ==(lhs: Model, rhs: Model) -> Bool {
            lhs.image == rhs.image && lhs.title == rhs.title && lhs.description == rhs.description
                && lhs.endDate == rhs.endDate && lhs.color == rhs.color && lhs.isDone == rhs.isDone
                && lhs.isLiked == rhs.isLiked && lhs.isLikeLoading == rhs.isLikeLoading
                && lhs.isDoneLoading == rhs.isDoneLoading
                && lhs.payload.anyEquatable.isEqual(to: rhs.payload.anyEquatable)
        }
    }
}

extension TaskView {
    class Cell: ViewNodeCellByView<TaskView> {
        typealias Model = CellViewModelByView<TaskView.Model, Cell>

        override var padding: UIEdgeInsets { .horizontal(16) + .vertical(8) }
    }
}

extension TaskView.Cell.Model {
    static let empty = TaskView.Cell.Model(.empty)

    static func makeTaskModel(from task: TaskModel, loadingLikesUIds: [String], loadingDoneUIds: [String]) -> TaskView.Cell.Model {
        let isExpired = task.endDate.map { Date() > $0 } ?? false

        return .init(.init(title: task.title.attrString,
                           image: task.imageUrl.map { .init(url: $0, placeholder: .init(shape: .bigSquircle, shapeColor: .accent), style: .big) },
                           description: task.description?.attrString,
                           endDate: task.endDate.map { DateFormatter.taskFull.string(from: $0) }?.attrString.apply(.empty.color(isExpired ? .destructive : .foreground2)),
                           color: task.color.uiColor,
                           isDone: task.isDone,
                           isDoneLoading: loadingDoneUIds.contains(task.uid),
                           isLiked: task.isLiked,
                           isLikeLoading: loadingLikesUIds.contains(task.uid),
                           name: task.ownerName?.attrString,
                           isInProgress: task.isInProgress,
                           payload: task), padding: .horizontal(16) + .vertical(8))
    }
}
