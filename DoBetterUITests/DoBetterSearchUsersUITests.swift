//
//  DoBetterSearchUsersUITests.swift
//  DoBetterUITests
//
//  Created by Никита Шестаков on 30.04.2023.
//

import XCTest

final class DoBetterSearchUsersUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["test", "mainTab"]
        app.launch()
        continueAfterFailure = false
        
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        app.navigationBars["Лента подписок"].children(matching: .button).element.tap()
    }

    func testFollow() throws {
        let button = app.tables.cells.containing(.staticText, identifier:"test2").children(matching: .button).element(boundBy: 0)
        button.tap()
        button.tap()
        app.navigationBars["test2"].children(matching: .button).element(boundBy: 0).tap()
    }

    func testSearch() throws {
        let loginField = app.tables.cells.containing(.textField, identifier:"Введите имя или логин").element
        loginField.tap()
        loginField.typeText("newText")
        loginField.waitForExistence(timeout: 2)
        
        let navigationBar = app.navigationBars["Пользователи"]
        XCTAssertTrue(navigationBar.staticTexts["Пользователи"].exists)
        XCTAssertTrue(app.tables.cells.count > 1, app.tables.tableRows.description)
    }

    func testHiddenProfile() throws {
        app.navigationBars["Пользователи"].children(matching: .button).element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["Поиск скрытого пользователя"].exists)
        
        XCTAssertTrue(app.buttons["Найти"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Найти"].isEnabled)
        let textField = app.tables.textFields["Введите логин"]
        textField.tap()
        textField.typeText("test3")
        XCTAssertTrue(app.buttons["Найти"].isEnabled)
        app.buttons["Найти"].tap()
        app.navigationBars["test3"].buttons["Пользователи"].tap()
    }

    func testUsersLayout() throws {
        XCTAssertTrue(app.tables.staticTexts["test2"].exists)
        XCTAssertTrue(app.tables.staticTexts["Description 2"].exists)
        XCTAssertTrue(app.tables.buttons["Доб."].exists)
    }
}
