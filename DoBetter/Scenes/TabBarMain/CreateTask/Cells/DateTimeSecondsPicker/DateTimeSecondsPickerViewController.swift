//
// Created by Никита Шестаков on 08.04.2023.
//

import Foundation
import UIKit

class DateTimeSecondsPickerViewController: UIViewController {
    var selectedDate: Date?

    private lazy var picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.date = selectedDate ?? Date()
        return picker
    }()

    override func loadView() {
        view = UIView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width,
                                   height: UIScreen.main.bounds.height * 0.3))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(picker)
    }
}
