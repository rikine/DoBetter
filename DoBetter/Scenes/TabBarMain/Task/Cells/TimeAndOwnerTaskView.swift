//
// Created by Никита Шестаков on 18.04.2023.
//

import Foundation
import ViewNodes

class TimeAndOwnerTaskView: VStack, Initializable {
    private(set) var userView: UserFlowView!
    private(set) var timeView: Text!
    private(set) var dateView: Text!
    private(set) var creator: Text!

    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }

    required override init() {
        super.init()

        config(backgroundColor: .clear)
        spacing(4)
        content {
            HStack().width(.fill).content {
                Text(Localization.Task.timeLeft.localized.apply(style: .line.secondary).interpolated())
                creator = Text(Localization.Task.creator.localized.apply(style: .line.secondary).interpolated())
            }

            HStack().width(.fill).alignment(.center).content {
                VStack().content {
                    timeView = Text()
                    dateView = Text()
                }

                userView = UserFlowView().padding(.left(4))
            }
        }
    }

    struct Model: ViewModel, Equatable, EquatableCellViewModel {
        let user: UserFlowView.Model?
        let endDate: Date?

        func setup(view: TimeAndOwnerTaskView) {
            user?.setup(view: view.userView)
            view.userView.hidden(user == nil)
            view.creator.hidden(user == nil)

            if let endDate {
                view.dateView.textOrHidden(DateFormatter.niceDate.string(from: endDate).apply(style: .body.foreground))
                view.setupTime(with: endDate)
            } else {
                view.timeView.text(Localization.Task.noDeadline.localized.apply(style: .title.foreground))
                view.dateView.hidden(true)
            }

            view.setupCooldown(with: endDate)
        }
    }

    func setupCooldown(with endDate: Date?) {
        guard let endDate else {
            timer = nil
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.setupTime(with: endDate)
        }
    }

    func setupTime(with endDate: Date) {
        let diff = Date().distance(to: endDate)
        let text: String
        if diff >= 86400 { text = Localization.Task.moreThanDay.localized }
        else if diff <= 0 { text = Localization.Task.expired.localized }
        else { text = TimeInterval.customString(from: diff, with: .hours, .minutes) }

        timeView.text(text.apply(style: .title.foreground))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        timer = nil
    }
}

extension TimeAndOwnerTaskView {
    class Cell: ViewNodeCellByView<TimeAndOwnerTaskView> {
        typealias Model = CellViewModelByView<TimeAndOwnerTaskView.Model, Cell>
    }
}

extension TimeInterval {
    static func seconds(from time: Self) -> Int { Int(time) % 60 }

    static func minutes(from time: Self) -> Int { (Int(time) / 60 ) % 60 }

    static func hours(from time: Self) -> Int { Int(time) / 3600 }

    static func customString(from time: Self, with components: Components...) -> String {
        let seconds: Int?
        let minutes: Int?
        let hours: Int?
        var stringFormat = ""

        func appendingToString(_ newSuffix: String) -> String {
            stringFormat.isEmpty ? newSuffix : (" " + newSuffix)
        }

        if components.contains(.hours) {
            hours = Self.hours(from: time)
            stringFormat += appendingToString("%dh")
        } else {
            hours = nil
        }

        if components.contains(.minutes) {
            minutes = Self.minutes(from: time)
            stringFormat += appendingToString("%dm")
        } else {
            minutes = nil
        }

        if components.contains(.seconds) {
            seconds = Self.seconds(from: time)
            stringFormat += appendingToString("%dd")
        } else {
            seconds = nil
        }

        return String(format: stringFormat, arguments: [hours, minutes, seconds].flatten())
    }

    enum Components {
        case minutes, hours, seconds
    }
}