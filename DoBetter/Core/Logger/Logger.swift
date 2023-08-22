//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

extension Logger {
    static private var standardRecorders: [LogRecorderType] { [CommonLogRecorder()] }
    static private var debugRecorders: [LogRecorderType] { [DebugConsoleRecorder()] }

    /// Принтит с датой и временем для релиз и энтерпрайз, и через print в дебаге
    static let common = standard(.common)
    static let socket = standard(.socket)
    static let lifecycle = standard(.lifecycle)
    static let networking = standard(.networking)

    /// Принтит только в консоль аппКода/хКода
    enum Debug {
        public static let keychain = debug(.keychain)

        /// Используется для "поиграться" во время разработки, в общем случае использовать через printDebug(_:)
        public static let local = debug(.local)
    }
}

class Logger {
    /// Область, в рамках которой записываем логи
    let scope: LogScope
    /// Рекордеры логов. Записывают логи туда, куда хотят (консоль, файл, ...)
    let logRecorders: [LogRecorderType]

    init(scope: LogScope, logRecorders: [LogRecorderType]) {
        self.scope = scope
        self.logRecorders = logRecorders
    }

    func debug(_ items: Any...) { log(.debug, items) }
    func info(_ items: Any...) { log(.info, items) }
    func warning(_ items: Any...) { log(.warning, items) }
    func error(_ items: Any...) { log(.error, items) }
    func critical(_ items: Any...) { log(.critical, items) }

    /// Логирует переданные параметры с помощью логРекордеров
    ///
    /// - Parameters:
    ///   - level: Уровень лога (info, critical, ...)
    ///   - items: Айтемы для логирования
    ///   - separator: Сепаратор между айтемами (аля print)
    ///   - terminator: Строка в конце айтомов (аля print)
    func log(_ level: LogLevel, _ items: [Any], separator: String = " ", terminator: String = "") {
        logRecorders.forEach {
            $0.log(scope: scope, level: level, items: items, separator: separator, terminator: terminator)
        }
    }

    func log(_ level: LogLevel, _ items: Any..., separator: String = " ", terminator: String = "") {
        log(level, items, separator: separator, terminator: terminator)
    }
}

private extension Logger {
    static func standard(_ scope: LogScope) -> Logger {
        Logger(scope: scope, logRecorders: standardRecorders)
    }

    static func debug(_ scope: LogScope) -> Logger {
        Logger(scope: scope, logRecorders: debugRecorders)
    }
}
