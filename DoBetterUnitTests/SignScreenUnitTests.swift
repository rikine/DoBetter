//
//  SignScreenUnitTests.swift
//  DoBetterUnitTests
//
//  Created by Никита Шестаков on 27.04.2023.
//

import XCTest
@testable import DoBetter

final class SignScreenUnitTests: XCTestCase {
    typealias Model = SignModelPresenter

    func testNickname() throws {
        try Data.nicknames.forEach { data in
            data.shouldThrow
            ? XCTAssertThrowsError(try Model.check(nickname: data.data), data.data ?? "")
            : XCTAssertNoThrow(try Model.check(nickname: data.data), data.data ?? "")
        }
    }
    
    func testEmail() throws {
        try Data.emails.forEach { data in
            data.shouldThrow
            ? XCTAssertThrowsError(try Model.check(email: data.data), data.data ?? "")
            : XCTAssertNoThrow(try Model.check(email: data.data), data.data ?? "")
        }
    }
    
    func testPassword() throws {
        try Data.password.forEach { data in
            data.shouldThrow
            ? XCTAssertThrowsError(try Model.check(password: data.data), data.data ?? "")
            : XCTAssertNoThrow(try Model.check(password: data.data), data.data ?? "")
        }
    }
    
    func testReenterPassword() throws {
        try Data.reenterPassword.forEach { data1, data2, shouldThrow in
            shouldThrow
            ? XCTAssertThrowsError(try Model.check(password: data1, reenteredPassword: data2), (data1 ?? "") + " " + (data2 ?? ""))
            : XCTAssertNoThrow(try Model.check(password: data1, reenteredPassword: data2), (data1 ?? "") + " " + (data2 ?? ""))
        }
    }
    
    func testPhone() throws {
        try Data.phones.forEach { data in
            data.shouldThrow
            ? XCTAssertThrowsError(try Model.check(phone: data.data), data.data ?? "")
            : XCTAssertNoThrow(try Model.check(phone: data.data), data.data ?? "")
        }
    }
    
    private struct Data {
        let shouldThrow: Bool
        let data: String?

        init(shouldThrow: Bool = false, data: String?) {
            self.shouldThrow = shouldThrow
            self.data = data
        }

        static var nicknames: [Data] {
            [
                .init(data: nil),
                .init(data: "rikine"),
                .init(data: "Rikine"),
                .init(data: "123Rikine123"),
                .init(data: "RIKINE"),
                .init(data: "1234"),
                .init(data: "Rikine_"),
                .init(data: "rikine!"),
                .init(data: "rikine#"),
                .init(data: "rikine&"),
                .init(data: "rikine("),
                .init(data: "rikine)"),
                .init(data: "rikine+"),
                .init(data: "rikine."),
                .init(data: "rikine.grwngwiGNWROIAHGNWRAOHIRANRHIOgionrdehoiaekrnhoarhglake"),
                .init(shouldThrow: true, data: "рикине"),
                .init(shouldThrow: true, data: ""),
                .init(shouldThrow: true, data: "rikine]"),
                .init(shouldThrow: true, data: "rikine["),
                .init(shouldThrow: true, data: "rikine!\\gsdGEWhgewiuGHWEIhgiwegnseoihnersoihnesoih")
            ]
        }
        
        static var emails: [Data] {
            [
                .init(data: nil),
                .init(data: "example@email.com"),
                .init(data: "example.first.middle.lastname@email.com"),
                .init(data: "example@subdomain.email.com"),
                .init(data: "example+firstname+lastname@email.com"),
                .init(data: "0987654321@example.com"),
                .init(data: "_______@email.com"),
                .init(data: "example@email-one.com"),
                .init(data: "example@email.co.jp"),
                .init(data: "example.firstname-lastname@email.com"),
                .init(data: ".example@email.com"),
                .init(data: "example@-email.com"),
                .init(data: "example%@-email.com"),
                .init(shouldThrow: true, data: ""),
                .init(shouldThrow: true, data: "“example”@email.com"),
                .init(shouldThrow: true, data: "plaintextaddress"),
                .init(shouldThrow: true, data: "@#@@##@%^%#$@#$@#.com"),
                .init(shouldThrow: true, data: "@email.com"),
                .init(shouldThrow: true, data: "John Doe <example@email.com>"),
                .init(shouldThrow: true, data: "example.email.com"),
                .init(shouldThrow: true, data: "example@example@email.com"),
                .init(shouldThrow: true, data: "おえあいう@example.com"),
                .init(shouldThrow: true, data: "example@email.com (John Doe)"),
                .init(shouldThrow: true, data: "example@111.222.333.44444"),
                .init(shouldThrow: true, data: "example@email…com"),
                .init(shouldThrow: true, data: "example@234.234.234.234"),
                .init(shouldThrow: true, data: "example@[234.234.234.234]"),
            ]
        }
        
        static var password: [Data] {
            [
                .init(data: nil),
                .init(data: "Password"),
                .init(data: "12345678"),
                .init(data: "123456789"),
                .init(data: "ABCABCDE"),
                .init(data: "ABCABCDE123!"),
                .init(data: "ABCABCDE123#"),
                .init(data: "ABCABCDE123$"),
                .init(data: "ABCABCDE123("),
                .init(data: "ABCABCDE123)"),
                .init(data: "ABCABCDE123+"),
                .init(data: "ABCABCDE123-"),
                .init(data: "ABCABCDE123_"),
                .init(data: "ABCABCDE123*"),
                .init(data: "ABCABCDE123^"),
                .init(data: "ABCABCDE123?"),
                .init(shouldThrow: true, data: "РИКИНЕ123"),
                .init(shouldThrow: true, data: "РИКИНЕ>"),
                .init(shouldThrow: true, data: "РИКИНЕ@"),
                .init(shouldThrow: true, data: "Qwerty"),
                .init(shouldThrow: true, data: "おえあいう"),
                .init(shouldThrow: true, data: "Letmein"),
                .init(shouldThrow: true, data: "1234567"),
                .init(shouldThrow: true, data: "рикине1234"),
                .init(shouldThrow: true, data: ""),
            ]
        }
            
        static var reenterPassword: [(String?, String?, Bool)] {
            [
                (nil, nil, false),
                (nil, "", true),
                (nil, "12345678", true),
                ("", "", true),
                ("", "12345678", true),
                ("1234567", "1234567", true),
                ("1234567", "", true),
                ("1234567", "12345678", true),
                ("12345678", "12345678", false),
                ("12345678", "", true),
                ("12345678", "123456789", true),
            ]
        }
        
        static var phones: [Data] {
            [
                .init(data: nil),
                .init(data: "+1 206 555 0100"),
                .init(data: "+44 113 496 0999"),
                .init(data: "+14255550123"),
                .init(data: "+79615345267"),
                .init(shouldThrow: true, data: "89617843679"),
                .init(shouldThrow: true, data: "+97843679"),
                .init(shouldThrow: true, data: "1234"),
                .init(shouldThrow: true, data: ""),
            ]
        }
    }
}
