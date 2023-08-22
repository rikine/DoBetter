//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

public enum LogLevel: String {
    case debug, info, warning, error, critical

    var displayName: String { "[\(rawValue.uppercased())]" }
}

/// Область, в рамках которой записываем логи. Сделано для удобного разделения (запросы, сокеты, итд)
/// При необходимости добавить еще области
public enum LogScope: String {
    case common, socket, networking, lifecycle, local, keychain

    var displayName: String { "[\(rawValue.uppercased())]" }
}

/// Тип рекордера логов. Нужно реализовать функцию `write(string:)`
/// с записью в нужное место (консоль, системные логи, файл, удаленный сервер я не знаю)
protocol LogRecorderType {
    func log(scope: LogScope, level: LogLevel, items: [Any], separator: String, terminator: String)
    /// Это надо реализовать в подписавшемся классе
    func write(string: String)
}

extension LogRecorderType {
    func log(scope: LogScope, level: LogLevel, items: [Any], separator: String, terminator: String) {
        let stringItems = items
            .map { "\($0)" }
            .joined(separator: separator)
            + terminator

        let tagsWithSpace = "\(level.displayName) \(scope.displayName) "
        let resultStringItems = tagsWithSpace + stringItems.split(separator: "\n").joined(separator: "\n" + tagsWithSpace)

        write(string: resultStringItems)
    }
}
