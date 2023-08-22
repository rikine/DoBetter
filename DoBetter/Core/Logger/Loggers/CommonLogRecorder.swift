//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation

/// Рекордер, который для дебажный сборок делает print, чтобы не отображать дату и время лога,
/// а для энтерпрайз и релиза делает NSLog с датой и временем лога
/// - используется как дефолтный
class CommonLogRecorder: LogRecorderType {

    private let osLogRecorder = OSLogRecorder()
    private let debugConsoleRecorder = DebugConsoleRecorder()

    func write(string: String) {
        #if DEBUG
            debugConsoleRecorder.write(string: string)
        #else
            osLogRecorder.write(string: string)
        #endif
    }
}
