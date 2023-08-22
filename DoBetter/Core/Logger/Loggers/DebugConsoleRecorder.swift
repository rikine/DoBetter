//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

/// Рекордер, который пишет только в дебаг консоль (принтит только)
///
/// Формат вывода:
/// [DEBUG] [FOO] bar baz
class DebugConsoleRecorder: LogRecorderType {
    func write(string: String) {
        debugPrint(string)
    }
}
