//
// Created by Никита Шестаков on 15.04.2023.
//

import Foundation
import ViewNodes
import UIKit

/// https://www.figma.com/file/44eGp3pYzBlYpYGeTRvrNt/Целевой-UI-Kit?node-id=25159%3A314878&t=F68XIVs8r0TqRCPB-4
class SettingView: HStack, Initializable {
    private(set) var textIconView: TextIconView!
    private(set) var switcher: Switch!

    override required init() {
        super.init()
        spacing(16)
        alignment(.center)
        config(backgroundColor: .clear)
        padding(.vertical(12) + .horizontal(16))
        content {
            textIconView = TextIconView()
                    .width(.fill)
            switcher = Switch()
                    .onTintColor(.accent)
                    .thumbTintColor(.constantWhite)
        }
    }

    struct Model: ViewModel, UpdatableWithoutReloadingRow, PayloadableCellModel, Equatable, EquatableCellViewModel {
        typealias Icon = ImageWithBadge.Model

        let model: TextIconView.Model
        var isSwitcherOn: Bool
        let disabledModel: IconModel.DisabledModel?

        var isDisabled: Bool { disabledModel != nil }

        var payload: CellModelPayload?

        init(title: AttrString, caption: AttrString? = nil, icon: Icon? = nil,
             isSwitcherOn: Bool = false, disabledModel: IconModel.DisabledModel? = nil) {
            let textColor: UIColor = disabledModel == nil ? .foreground : .foreground2
            self.model = .init(title: title.apply(textStyle: .line.color(textColor)),
                               caption: caption?.apply(textStyle: .label.color(textColor)),
                               icon: icon)
            self.isSwitcherOn = isSwitcherOn
            self.disabledModel = disabledModel
        }

        func setup(view: SettingView) {
            commonSetup(view: view)
            view.switcher.isOn(isSwitcherOn, animated: false)
        }

        func update(cell: SettingView) {
            commonSetup(view: cell)
            cell.switcher.isOn(isSwitcherOn, animated: true)
        }

        private func commonSetup(view: SettingView) {
            view.textIconView.imageWithBadge.icon.disabledModel(disabledModel)
            view.isUserInteractionEnabled = !isDisabled
            view.switcher.onTintColor(isDisabled ? .content2 : .accent).thumbTintColor(isDisabled ? .foreground4 : .constantWhite)
            model.setup(view: view.textIconView)
            view.background(color: .content2).corner(radius: 8)
        }

        static func ==(lhs: Model, rhs: Model) -> Bool {
            lhs.model == rhs.model
                && lhs.isSwitcherOn == rhs.isSwitcherOn
                && lhs.disabledModel == rhs.disabledModel
                && (lhs.payload?.isEqual(to: rhs.payload) ?? false)
        }
    }
}

extension SettingView {
    class Cell: ViewNodeCellByView<SettingView> {
        typealias Model = CellViewModelByView<SettingView.Model, Cell>

        override func prepareForReuse() {
            super.prepareForReuse()
            mainView.textIconView.prepareForReuse()
        }
    }
}
