//
//  ComponentsUnitTests.swift
//  DoBetterUnitTests
//
//  Created by Никита Шестаков on 28.04.2023.
//

import XCTest
@testable import ViewNodes
@testable import DoBetter

final class ComponentsUnitTests: XCTestCase {
    private let (sutSnack, sutSnackParent) = TestUtils.setupSut(CommonSnack(), SnackBar())
    private let (sutSettings, sutSettingsParent) = TestUtils.setupSut(SettingView().width(.fill), ZStack())
    private let (sutButtonBar, sutButtonBarParent) = TestUtils.setupSut(ButtonBarStack().width(.fill), ZStack())
    private let (sutUserFlow, sutUserFlowParent) = TestUtils.setupSut(UserFlowView(), ZStack())
    private let (sutProfileUserFlow, sutProfileUserParent) = TestUtils.setupSut(ProfileUserView(), ZStack())
    private let (sutSearchUserFlow, sutSearchUserParent) = TestUtils.setupSut(SearchUserView(), ZStack())
    private let (sutColorPicker, sutColorPickerParent) = TestUtils.setupSut(ColorPickerView(), ZStack())
    private let (sutSectionPicker, sutSectionPickerParent) = TestUtils.setupSut(TaskSectionPickerView(), ZStack())
    private let (sutInput, sutInputParent) = TestUtils.setupSut(Input(), ZStack())
    private let (sutBSHeadline, sutBSHeadlineParent) = TestUtils.setupSut(BottomSheetHeadlineView(), ZStack())
    private let (sutUploadImage, sutUploadImageParent) = TestUtils.setupSut(UploadImageView(), ZStack())
    private let (sutCheckbox, sutCheckboxParent) = TestUtils.setupSut(CheckboxView(), ZStack())
    private let (sutTextArea, sutTextAreaParent) = TestUtils.setupSut(TextAreaView(), ZStack())
    private let (sutTask, sutTaskParent) = TestUtils.setupSut(TaskView(), ZStack())
    
    // MARK: - CommonSnack
    
    /// Иконка у обычного снека должна быть выравнена по высоте
    func testCommonSnackIconAlignedToTop() throws {
        for string in TestUtils.testStrings().flatten() {
            try verifySnackIconAlignedToTop(with: commonSnack(text: string))
        }
    }
    
    private func verifySnackIconAlignedToTop(with model: CommonSnack.Model) throws {
        let image = try XCTUnwrap(sutSnack.imageStack.contentView)
        
        sutSnack.apply(model: model)
        
        XCTAssertEqual(image.absoluteFrame.minY, 12, "Icon not aligned to top with text: \(model.text.string)")
    }
    
    /// Высота всего снека не должна быть меньше, чем высота иконки
    func testCommonSnackImageBadgeTallerThanItsIconModel() throws {
        let icon = IconModel.empty(ofSize: 40)
        
        sutSnack.apply(model: commonSnack(icon: icon, text: "test"))
        
        XCTAssertGreaterThanOrEqual(sutSnack.imageStack.contentView.frame.height, icon.size.height)
    }
    
    private func commonSnack(icon: IconModel = IconModel.empty(ofSize: 40), text: String) -> CommonSnack.Model {
        CommonSnack.Model(icon: icon, text: text.toAttrString)
    }
    
    // MARK: - Settings
    
    func testSettingView() throws {
        let switcher = try XCTUnwrap(sutSettings.switcher)
        
        let text = "test"
        [true, false].forEach { isOn in
            commonSetting(test: text, isOn: isOn).setup(view: sutSettings)
            sutSettingsParent.layoutIfNeeded()
            
            XCTAssertTrue(sutSettings.spacingValue == 16)
            XCTAssertTrue(sutSettings.paddingInsets == .vertical(12) + .horizontal(16))
            XCTAssertTrue(sutSettings.alignmentValue == .center)
            XCTAssertTrue(sutSettings.textIconView.size.width == .fill)
            XCTAssertTrue(switcher.isOn == isOn)
            XCTAssertTrue(sutSettings.textIconView.title.wrapped.text == text)
            XCTAssertTrue(sutSettings.bounds.width - switcher.absoluteFrame.origin.x - switcher.absoluteFrame.width == 16)
        }
    }
    
    private func commonSetting(test: String, isOn: Bool) -> SettingView.Model {
        .init(title: test.attrString, isSwitcherOn: isOn)
    }
    
    // MARK: Button Bar Stack
    
    func testButtonBarStack() throws {
        let buttonGroup = try XCTUnwrap(sutButtonBar.buttonGroup)
        let stackWrapper = try XCTUnwrap(sutButtonBar.stackWrapper)
        
        for buttons in ButtonModel.testModels {
            let model = commonButtonBar(buttons: buttons, hasSeparator: Bool.random())
            model.setup(view: sutButtonBar)
            sutButtonBarParent.layoutIfNeeded()
            
            XCTAssertTrue(stackWrapper.paddingInsets == .all(16))
            XCTAssertTrue(stackWrapper.spacingValue == 15)
            XCTAssertTrue(buttonGroup.spacingValue == 16)
            XCTAssertTrue(sutButtonBar.size.width == .fill)
            XCTAssertFalse(sutButtonBar.lineValue!.isHidden == model.hasSeparator)
            XCTAssertTrue(sutButtonBar.lineValue!.edge == .top)
            XCTAssertTrue(buttonGroup.visibleSubviewsOf.count == buttons.count)
            
            for (index, button) in buttons.enumerated() {
                let uiButtonWrapper = buttonGroup.visibleSubviewsOf[index]
                let uiButton = uiButtonWrapper.wrapped
                XCTAssertTrue(uiButton.titleLabel?.text == button.text)
                XCTAssertTrue(uiButton.style == button.style)
                XCTAssertTrue(uiButton.isEnabled == button.isEnabled)
                XCTAssertTrue(uiButtonWrapper.size.height == button.height, "\(uiButtonWrapper.size.height) \(button.height)")
            }
        }
    }
    
    private struct ButtonModel {
        let text: String
        let isEnabled: Bool
        let height: View.Size.Dimension
        let style: IBRoundCornersButton.Style
        
        static let testModels: [[ButtonModel]] = {
            [
                [
                    .init(text: TestUtils.testString(count: 10),
                          isEnabled: true,
                          height: .equal(52),
                          style: .primary)
                ],
                [
                    .init(text: TestUtils.testString(count: 50),
                          isEnabled: true,
                          height: .equal(52),
                          style: .primary),
                    .init(text: TestUtils.testString(count: 10),
                          isEnabled: false,
                          height: .equal(52),
                          style: .secondary),
                    .init(text: TestUtils.testString(count: 30),
                          isEnabled: true,
                          height: .equal(52),
                          style: .text),
                ],
                [
                    .init(text: TestUtils.testString(count: 100),
                          isEnabled: false,
                          height: .equal(40),
                          style: .loading)
                ]
            ]
        }()
    }
    
    private func commonButtonBar(buttons: [ButtonModel], hasSeparator: Bool) -> ButtonBarStack.Model {
        .init(hasSeparator: hasSeparator, buttons: buttons.map {
            .init(text: $0.text, style: $0.style, isEnabled: $0.isEnabled, height: $0.height.equalValue)
        })
    }
    
    // MARK: UserFlowView
    
    func testUserFlowView() throws {
        for (nickname, image) in TestUtils.testStrings()
            .zip(with: Array(repeating: IconModel.empty(ofSize: .square(56)),
                             count: Array<Int>.defaultTestStringLenghts.count)) {
                
                let model = UserFlowView.Model(icon: .init(url: nil, placeholder: image), nickname: nickname.attrString)
                model.setup(view: sutUserFlow)
                sutUserFlowParent.layoutIfNeeded()
                
                XCTAssertTrue(sutUserFlow.paddingInsets == .vertical(8))
                XCTAssertTrue(sutUserFlow.spacingValue == 8)
                XCTAssertTrue(sutUserFlow.cornerValue?.radius == 8)
                XCTAssertTrue(sutUserFlow.image.size.height.equalValue == 56)
                XCTAssertTrue(sutUserFlow.image.size.width.equalValue == 56)
                XCTAssertTrue(sutUserFlow.nickname.wrapped.text == nickname)
                XCTAssertTrue(sutUserFlow.nickname.wrapped.numberOfLines == 2, "\(sutUserFlow.nickname.wrapped.numberOfLines)")
            }
    }
    
    // MARK: ProfileUser
    
    func testProfileUserView() throws {
        for (((nickname, name), image), button) in TestUtils.testStrings().flatten()
            .zip(with: TestUtils.testStrings(withNils: true))
            .zip(with: Array(repeating: IconModel.empty(ofSize: .square(80)),
                             count: Array<Int>.defaultTestStringLenghts.count))
                .zip(with: [RoundCornersButton.Model.Mode.add, .remove]
                     + Array(repeating: .add, count: Array<Int>.defaultTestStringLenghts.count))
        {
            
            let model = ProfileUserView.Model(icon: .init(url: nil, placeholder: image, style: .large),
                                              nickname: nickname,
                                              name: name,
                                              button: .Mode.makeModel(for: button, isLoading: false, action: {}))
            model.setup(view: sutProfileUserFlow)
            sutProfileUserParent.layoutIfNeeded()
            
            XCTAssertTrue(sutProfileUserFlow.paddingInsets == .all(16))
            XCTAssertGreaterThanOrEqual(sutProfileUserFlow.bounds.height, 32 + 16 * 2 + 80 + 16)
            XCTAssertTrue(sutProfileUserFlow.image.size.height.equalValue == 80)
            XCTAssertTrue(sutProfileUserFlow.image.size.width.equalValue == 80)
            XCTAssertTrue(sutProfileUserFlow.button.wrapped.style == button.style, "\(sutProfileUserFlow.button.wrapped.style) \(button.style)")
            XCTAssertTrue(sutProfileUserFlow.button.wrapped.titleLabel?.text == button.title)
            XCTAssertTrue(sutProfileUserFlow.nickname.wrapped.text == nickname)
            XCTAssertTrue(sutProfileUserFlow.name.wrapped.text == name)
        }
    }
    
    // MARK: SearchUserView
    
    func testSearchUserView() throws {
        for (((title, subtitle), image), button) in TestUtils.testStrings().flatten()
            .zip(with: TestUtils.testStrings().flatten())
            .zip(with: Array(repeating: IconModel.empty(ofSize: .square(40)),
                             count: Array<Int>.defaultTestStringLenghts.count))
                .zip(with: [RoundCornersButton.Model.Mode.add, .remove]
                     + Array(repeating: .add, count: Array<Int>.defaultTestStringLenghts.count))
        {
            
            let model = SearchUserView.Model(image: .init(url: nil, placeholder: image, style: .common),
                                             title: title,
                                             subtitle: subtitle,
                                             button: .Mode.makeModel(for: button, isLoading: false, action: {}))
            model.setup(view: sutSearchUserFlow)
            sutSearchUserParent.layoutIfNeeded()
            
            XCTAssertTrue(sutSearchUserFlow.spacingValue == 8)
            XCTAssertTrue(sutSearchUserFlow.paddingInsets == .all(12))
            XCTAssertTrue(sutSearchUserFlow.size.width == .fill)
            XCTAssertTrue(sutSearchUserFlow.alignmentValue == .center)
            XCTAssertTrue(sutSearchUserFlow.image.size.height.equalValue == 40)
            XCTAssertTrue(sutSearchUserFlow.image.size.width.equalValue == 40)
            XCTAssertTrue(sutSearchUserFlow.subtitle.wrapped.numberOfLines == 4)
            XCTAssertGreaterThanOrEqual(sutSearchUserFlow.bounds.height, 40 + 12 * 2)
            XCTAssertTrue(sutSearchUserFlow.subtitle.wrapped.text == subtitle)
            XCTAssertTrue(sutSearchUserFlow.title.wrapped.text == title)
            XCTAssertTrue(sutSearchUserFlow.button.wrapped.style == button.style)
            XCTAssertTrue(sutSearchUserFlow.button.wrapped.titleLabel?.text == button.title)
        }
    }
    
    // MARK: ColorPickerView
    
    func testColorPicker() throws {
        for color in TaskModel.Color.allCases {
            let isSelected = Bool.random()
            ColorPickerView.Model(color: color, isSelected: isSelected).setup(view: sutColorPicker)
            sutColorPickerParent.layoutIfNeeded()
            
            XCTAssertTrue(sutColorPicker.size.width.equalValue == 32)
            XCTAssertTrue(sutColorPicker.size.height.equalValue == 32)
            XCTAssertTrue(sutColorPicker.borderValue?.width == 3)
            XCTAssertTrue(sutColorPicker.cornerValue?.radius == 8)
            XCTAssertTrue(sutColorPicker.cornerValue?.masksToBounds == true)
            
            XCTAssertTrue(sutColorPicker.backgroundColor != nil)
            XCTAssertTrue(isSelected ? sutColorPicker.wrapped.iconModel != nil : sutColorPicker.wrapped.iconModel == nil)
        }
    }
    
    // MARK: SectionPickerView
    
    func testSectionPicker() throws {
        for section in SectionModel.allCases {
            let isSelected = Bool.random()
            TaskSectionPickerView.Model(section: section, isSelected: isSelected).setup(view: sutSectionPicker)
            sutSectionPickerParent.layoutIfNeeded()
            
            XCTAssertTrue(sutSectionPicker.paddingInsets == .all(8))
            XCTAssertTrue(sutSectionPicker.borderValue?.width == 3)
            XCTAssertTrue(sutSectionPicker.cornerValue?.radius == 16)
            XCTAssertTrue(sutSectionPicker.cornerValue?.masksToBounds == true)
            
            XCTAssertTrue(sutSectionPicker.backgroundColor != nil)
            XCTAssertTrue(isSelected ? sutSectionPicker.backgroundColor != nil : true)
            XCTAssertTrue(sutSectionPicker.text.wrapped.text == section.localized)
        }
    }
    
    // MARK: Input
    
    func testInputPicker() throws {
        for ((((label, placeholder), info), value), icon) in TestUtils.testStrings(withNils: true)
            .zip(with: TestUtils.testStrings().flatten())
            .zip(with: TestUtils.testStrings(withNils: true))
            .zip(with: TestUtils.testStrings(withNils: true))
            .zip(with: TestUtils.testIcons(size: 40, withNils: true)) {
             let model = SignModelPresenter.makeInputCell(inputID: CommonInputID(rawValue: label ?? ""), placeholder: placeholder, label: label,
                                             value: value, info: info, leftIcon: icon, isSecure: Bool.random(),
                                             isPhone: Bool.random())
                .inputModel
            model.setup(view: sutInput)
            sutInputParent.layoutIfNeeded()
            
            XCTAssertTrue(sutInput.inputStack.spacingValue == 8)
            XCTAssertTrue(sutInput.inputStack.alignmentValue == .center)
            XCTAssertTrue(sutInput.inputStack.paddingInsets == .horizontal(12))
            XCTAssertTrue(sutInput.inputStack.cornerValue?.radius == 8)
            XCTAssertTrue(sutInput.inputStack.size.height.equalValue == 44)
            XCTAssertTrue(sutInput.inputStack.lineValue?.edge == .bottom)

            XCTAssertTrue(sutInput.textFieldWrapper.size.height.equalValue == 20)
            XCTAssertTrue(sutInput.textFieldWrapper.size.width == .fill)
            
            XCTAssertTrue(sutInput.textField.placeholder ?? "" == placeholder)
            XCTAssertTrue(sutInput.textField.text == value ?? "")
            XCTAssertTrue(sutInput.label.wrapped.text == label && sutInput.label.isHidden == (label == nil))
            XCTAssertTrue(sutInput.info.wrapped.text == info && sutInput.info.isHidden == (info == nil))
            XCTAssertTrue(sutInput.leftIcon.wrapped.iconModel == icon && sutInput.leftIcon.isHidden == (icon == nil))
        }
    }
    
    // MARK: Spacer
    
    private let (sutSpacer, sutSpacerParent) = TestUtils.setupSut(SpacerView(), ZStack())
    
    func testSpacer() throws {
        for color in [UIColor.foreground, .foreground4, .foreground3, .foreground2] {
            SpacerView.Model(color: color).setup(view: sutSpacer)
            sutSpacerParent.layoutIfNeeded()
            
            XCTAssertTrue(sutSpacer.size.height.equalValue == 1)
            XCTAssertTrue(sutSpacer.lineValue?.edge == .bottom)
            XCTAssertTrue(sutSpacer.lineValue?.color == color)
            XCTAssertFalse(sutSpacer.size.width.equalValue != nil)
            XCTAssertFalse(sutSpacer.lineValue?.isHidden == true)
        }
    }
    
    // MARK: BottomSheetHeadlineView
    
    func testBSHeadline() throws {
        for ((headline, caption), rightText) in TestUtils.testStrings(withNils: true)
            .zip(with: TestUtils.testStrings(withNils: true))
            .zip(with: TestUtils.testStrings(withNils: true)) {
            
            BottomSheetHeadlineView.Model(headline: headline?.attrString, caption: caption?.attrString, rightText: rightText?.attrString).setup(view: sutBSHeadline)
            sutBSHeadlineParent.layoutIfNeeded()
            
            XCTAssertTrue(sutBSHeadline.spacingValue == 16)
            XCTAssertTrue(sutBSHeadline.paddingInsets == .horizontal(16) + .vertical(12) + .top(12))
            XCTAssertTrue(sutBSHeadline.headline.size.width == .fill)
            XCTAssertTrue(sutBSHeadline.caption.size.width == .fill)
            XCTAssertTrue(sutBSHeadline.caption.paddingInsets == .bottom(3))
            XCTAssertTrue(sutBSHeadline.headline.paddingInsets == (caption == nil ? .top(8) + .bottom(7) : .top(4)))
            XCTAssertTrue(sutBSHeadline.headline.wrapped.text == headline)
            XCTAssertTrue(sutBSHeadline.caption.wrapped.text == caption)
            XCTAssertTrue(sutBSHeadline.rightText.wrapped.text == rightText)
        }
    }
    
    // MARK: UploadImageView
    
    func testUploadImageView() throws {
        let image = IconModel.empty(ofSize: .square(80))
        UploadImageView.Model(image: .init(url: nil, placeholder: image, style: .large)).setup(view: sutUploadImage)
        sutUploadImageParent.layoutIfNeeded()
        
        XCTAssertTrue(sutUploadImage.paddingInsets == .vertical(8))
        XCTAssertTrue(sutUploadImage.image.paddingInsets == .all(16))
        XCTAssertTrue(sutUploadImage.image.size.width.equalValue == 80)
        XCTAssertTrue(sutUploadImage.image.size.height.equalValue == 80)
        XCTAssertTrue(sutUploadImage.info.paddingInsets == .top(8))
        XCTAssertTrue(sutUploadImage.info.wrapped.text == Localization.imageUpload.localized)
        XCTAssertTrue(sutUploadImage.remove.paddingInsets == .top(8))
        XCTAssertTrue(sutUploadImage.remove.wrapped.text == Localization.deleteImage.localized)
    }
    
    // MARK: CheckboxView
    
    func testCheckbox() throws {
        for (info, text) in TestUtils.testStrings(withNils: true)
            .zip(with: TestUtils.testStrings().flatten()) {
            
            let isSelected = Bool.random() ? Bool.random() : nil
            CheckboxView.Model(text: text.attrString, info: info?.attrString, isSelected: isSelected).setup(view: sutCheckbox)
            sutCheckboxParent.layoutIfNeeded()
            
            XCTAssertTrue(sutCheckbox.spacingValue == 8)
            XCTAssertTrue(sutCheckbox.rightButton.size.height.equalValue == 24)
            XCTAssertTrue(sutCheckbox.rightButton.size.width.equalValue == 24)
            XCTAssertTrue(sutCheckbox.rightButton.cornerValue?.radius == 8)
            XCTAssertTrue(sutCheckbox.rightButton.cornerValue?.masksToBounds == true)
            XCTAssertTrue(sutCheckbox.rightButton.borderValue?.width == 1)
            XCTAssertTrue(sutCheckbox.text.wrapped.text == text)
            XCTAssertTrue(sutCheckbox.info.wrapped.text == info)
            
            let icon: IconModel
            switch isSelected {
            case true: icon = .Task.check
            case false: icon = .Task.remove
            default: icon = .Task.emptyCircle
            }
            
            XCTAssertTrue(sutCheckbox.rightButton.wrapped.iconModel == icon)
        }
    }
    
    // MARK: TaskView
    
    func testTaskView() throws {
        for task in CreateTaskRequest.tasks {
            TaskView.Cell.Model.makeTaskModel(from: task, loadingLikesUIds: [], loadingDoneUIds: []).mainViewModel.setup(view: sutTask)
            sutTaskParent.layoutIfNeeded()
            
            XCTAssertTrue(sutTask.cornerValue?.radius == 12)
            XCTAssertTrue(sutTask.cornerValue?.masksToBounds == true)
            XCTAssertTrue(sutTask.paddingInsets == .all(8))
            XCTAssertTrue(sutTask.size.width == .fill)
            
            XCTAssertTrue(sutTask.image.size.height.equalValue == 56)
            XCTAssertTrue(sutTask.image.size.width.equalValue == 56)
            
            XCTAssertTrue(sutTask.doneButton.size.height.equalValue == 24)
            XCTAssertTrue(sutTask.doneButton.size.height.equalValue == 24)
            XCTAssertTrue(sutTask.doneButton.cornerValue?.radius == 8)
            XCTAssertTrue(sutTask.doneButton.cornerValue?.masksToBounds == true)
            XCTAssertTrue(sutTask.doneButton.borderValue != nil)
            
            XCTAssertTrue(sutTask.likeButton.size.height.equalValue == 24)
            XCTAssertTrue(sutTask.likeButton.size.height.equalValue == 24)
            XCTAssertTrue(sutTask.likeButton.cornerValue?.radius == 8)
            XCTAssertTrue(sutTask.likeButton.cornerValue?.masksToBounds == true)
            
            XCTAssertTrue(sutTask.separator.size.height.equalValue == 1)
            
            XCTAssertTrue(sutTask.name.wrapped.numberOfLines == 0)
            
            XCTAssertTrue(sutTask.title.wrapped.text.emptyLet == task.title)
            XCTAssertTrue(sutTask.image.isHidden == (task.imageUrl == nil))
            XCTAssertTrue(sutTask.descriptionText.wrapped.text.emptyLet == task.description)
            XCTAssertTrue(sutTask.endDate.wrapped.text.emptyLet == task.endDate.map(DateFormatter.taskFull.string))
            XCTAssertTrue(sutTask.separator.isHidden == (task.ownerName == nil))
            XCTAssertTrue(sutTask.name.wrapped.text.emptyLet == task.ownerName)
        }
    }
    
    // MARK: TextAreaView
    
    func testTextAreaView() throws {
        for ((((label, info), text), placeholder), counter) in TestUtils.testStrings(withNils: true)
            .zip(with: TestUtils.testStrings(withNils: true))
            .zip(with: TestUtils.testStrings().flatten())
            .zip(with: TestUtils.testStrings(withNils: true))
            .zip(with: TestUtils.testStrings(withNils: true))
        {
            let isEditable = Bool.random()
            let isScrollEnabled = Bool.random()
            let height = Bool.random() ? Int.random(in: 0...300) : nil
            
            TextAreaView.Model(label: label?.style(.label),
                               info: info?.style(.label),
                               counter: counter?.style(.label),
                               textViewModel: .textAreaModel(text: text.style(.line),
                                                             placeholder: placeholder?.style(.line),
                                                             isEditable: isEditable,
                                                             isScrollEnabled: isScrollEnabled),
                               height: height.map(CGFloat.init)).setup(view: sutTextArea)
            sutTextAreaParent.layoutIfNeeded()
            
            XCTAssertTrue(sutTextArea.paddingInsets == .horizontal(16) + .vertical(12))
            XCTAssertTrue(sutTextArea.spacingValue == 4)
            XCTAssertTrue(sutTextArea.textView.cornerValue?.radius == 8)
            XCTAssertTrue(sutTextArea.textView.cornerValue?.masksToBounds == true)
            XCTAssertTrue(sutTextArea.info.size.width == .fill)
            XCTAssertTrue(sutTextArea.info.wrapped.numberOfLines == 0)
            XCTAssertTrue(sutTextArea.textView.wrapped.textContainerInset == .all(12))
            XCTAssertTrue(sutTextArea.textView.wrapped.isEditable == isEditable)
            XCTAssertTrue(sutTextArea.textView.wrapped.isScrollEnabled == isScrollEnabled)
            XCTAssertTrue(sutTextArea.textView.text == text)
            XCTAssertTrue(sutTextArea.label.wrapped.text.emptyLet == label.emptyLet)
            XCTAssertTrue(sutTextArea.info.wrapped.text.emptyLet == info.emptyLet)
            XCTAssertTrue(sutTextArea.counter.wrapped.text.emptyLet == counter.emptyLet)
            
            if let height {
                XCTAssertTrue(sutTextArea.textView.size.height.equalValue == CGFloat(height))
            }
        }
    }
}
