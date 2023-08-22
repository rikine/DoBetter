//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation

public class ShouldNeverHappen: NSError {

    public static let unpredictableError =
        NSLocalizedString("Возникла непредвиденная ошибка, пожалуйста, обратитесь в службу поддержки", comment: "")

    @discardableResult
    public static func error(additionalUserInfo: [String: Any] = [:], file: StaticString = #fileID, line: UInt = #line) -> ShouldNeverHappen {
        let errorUuid = NSUUID().uuidString
        let message: String = ShouldNeverHappen.unpredictableError + "\n" + errorUuid

        var info: [String: Any] = additionalUserInfo
        info["ErrorUuid"] = errorUuid
        info[NSLocalizedDescriptionKey] = message
        assertionFailure(message)
        return ShouldNeverHappen(domain: "open-broker.\(file).\(line)", code: 0, userInfo: info)
    }
}

@inline(__always)
public func assertionUnwrap<T>(optional: T?, file: StaticString = #fileID, line: UInt = #line) -> T {
    guard let optional = optional else {
        assertionFailure("Unwraped nil value \(String(reflecting: T.self))", file: file, line: line)
        return optional!
    }
    return optional
}


@inline(__always)
public func assertionCast<T>(_ object: Any?, to _: T.Type) -> T? {
    guard let object else { return nil }
    guard let casted = object as? T else {
        return guardUnreachable(nil, "Conform \(String(reflecting: type(of: object))) to \(String(reflecting: T.self))")
    }
    return casted
}

@discardableResult
@inline(__always)
public func unreachable(_ reportingReason: String? = nil, file: StaticString = #fileID, line: UInt = #line) -> ShouldNeverHappen {
    assertionFailure("Unreachable: \(reportingReason ?? "no reason provided")", file: file, line: line)
    return ShouldNeverHappen.error(additionalUserInfo: reportingReason.map { ["Reason": $0] } ?? [:],
                                   file: file,
                                   line: line)
}

@inline(__always)
public func guardUnreachable(_ reportingReason: String = "Unreachable guard failed",
                             file: StaticString = #fileID,
                             line: UInt = #line) {
    guardUnreachable((), reportingReason, file: file, line: line)
}

@inline(__always)
public func guardUnreachable<T>(_ x: T,
                                _ reportingReason: String = "Unreachable guard failed",
                                file: StaticString = #fileID,
                                line: UInt = #line) -> T {
    unreachable(reportingReason, file: file, line: line)
    return x
}
