//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

/// Рекордер, который пишет в системный логи + выводит в консоль xcode с датой и временем лога
///
/// Формат вывода:
/// 2022-07-14 10:27:42.249464+0300 OpenBroker[90279:1109800] [DEBUG] [FOO] bar baz
class OSLogRecorder: LogRecorderType {
    func write(string: String) {
        NSLog(string)
    }
}
