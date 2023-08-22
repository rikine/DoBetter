//
//  DoBetterProfileUITests.swift
//  DoBetterUITests
//
//  Created by Никита Шестаков on 01.05.2023.
//

import XCTest

final class DoBetterProfileUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["test", "mainTab"]
        app.launch()
        continueAfterFailure = false
        
        UserDefaults.standard.set(false, forKey: "BioAuthEnabled")
        app.navigationBars["Моя лента"].children(matching: .button).element.tap()
    }

    func testLayout() throws {
        XCTAssertTrue(app.navigationBars["test1"].staticTexts["test1"].exists)
        
        XCTAssertTrue(app.tables.cells.containing(.staticText, identifier:"test1").staticTexts["Test Name1"].exists)
        XCTAssertTrue(app.tables.cells.containing(.staticText, identifier:"test1").staticTexts["test1"].exists)

        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.staticTexts["Описание"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Описания ещё нет"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Статистика задач"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["В процессе"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Просрочено"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Готово"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Всего"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["Задачи"].exists)
        
        let allTasksButton = tablesQuery.cells.containing(.staticText, identifier: "Задачи").staticTexts["Все"]
        XCTAssertTrue(allTasksButton.exists)
        
        XCTAssertTrue(tablesQuery.staticTexts["title1"].exists)
        app.swipeUp()
        app.swipeUp()
        
        let followersCell = tablesQuery.cells.containing(.staticText, identifier: "Подписчики")
        XCTAssertTrue(followersCell.element.exists)
        
        XCTAssertTrue(tablesQuery.staticTexts["test6"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["test7"].exists)
        
        let followingsCell = tablesQuery.cells.containing(.staticText, identifier: "Подписки")
        XCTAssertTrue(followingsCell.element.exists)
        
        XCTAssertTrue(tablesQuery.staticTexts["test5"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["test6"].exists)
        XCTAssertTrue(tablesQuery.staticTexts["test7"].exists)
    }
    
    func testLinks() throws {
        let tablesQuery = app.tables
        let allTasksButton = tablesQuery.cells.containing(.staticText, identifier: "Задачи").staticTexts["Все"]
        allTasksButton.tap()
        XCTAssertTrue(app.staticTexts["Фильтры"].exists)
        XCTAssertFalse(app.images["CreateTask"].exists)
        app.navigationBars["Задачи"].children(matching: .button).element(boundBy: 0).tap()
        
        app.swipeUp()
        app.swipeUp()
        let followersCell = tablesQuery.cells.containing(.staticText, identifier: "Подписчики")
        followersCell.staticTexts["Все"].tap()
        app.navigationBars["Пользователи"].children(matching: .button).element(boundBy: 0).tap()
        
        let followingsCell = tablesQuery.cells.containing(.staticText, identifier: "Подписки")
        followingsCell.staticTexts["Все"].tap()
        app.navigationBars["Пользователи"].children(matching: .button).element(boundBy: 0).tap()
    }
    
    func testFollow() throws {
        XCTAssertFalse(app.buttons["Добавить"].exists)
    }
    
    func testEditingProfileLayout() throws {
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 2).tap()
        
        let navigationBar = app.navigationBars["Редактирование"]
        XCTAssertTrue(navigationBar.staticTexts["Редактирование"].exists)
        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.staticTexts["Введите свои фамилию и имя"].exists)
        
        XCTAssertTrue(tablesQuery.staticTexts["Введите логин"].exists)
        
        XCTAssertTrue(tablesQuery.staticTexts["Напишите что-нибудь о себе Например: 23 года, дизайнер из Санкт-Петербурга"].exists)
        XCTAssertTrue(tablesQuery.textFields["Введите имя"].exists)
        
        XCTAssertTrue(tablesQuery.textFields["Введите логин"].exists)
        
        XCTAssertTrue(tablesQuery.textViews.staticTexts["Введите описание"].exists)
        tablesQuery.textViews.containing(.staticText, identifier:"Введите описание").element.tap()
    }
    
    func testEditingProfileWrong() throws {
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 2).tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["Введите логин"].tap()
        for _ in 0...6 {
            app.keys["delete"].tap()
        }
        
        tablesQuery.textFields["Введите логин"].typeText("")
        
        let textField = tablesQuery.textFields["Введите имя"]
        textField.tap()
        textField.typeText("newLogin")
        
        let textView = tablesQuery.textViews.containing(.staticText, identifier:"Введите описание").element
        textView.tap()
        textView.typeText("New Description")

        let button = app.navigationBars["Редактирование"].children(matching: .button).element(boundBy: 1)
        button.tap()
        
        XCTAssertTrue(app.staticTexts["Логин должен быть заполнен"].exists)
        
        tablesQuery.textFields["Введите логин"].tap()
        tablesQuery.textFields["Введите логин"].typeText("!@#$%^&")
        button.tap()
        
        XCTAssertTrue(app.staticTexts["Некорректный логин Не должен содержать пробелы"].exists)
    }
    
    func testEditingProfile() throws {
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 2).tap()
        
        let tablesQuery = app.tables
        tablesQuery.textFields["Введите логин"].tap()
        tablesQuery.textFields["Введите логин"].typeText("newLogin")
        
        let button = app.navigationBars["Редактирование"].children(matching: .button).element(boundBy: 1)
        button.tap()
        
        XCTAssertTrue(app.navigationBars["test1"].exists)
    }
    
    func testSettingsLayout() throws {
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 1).tap()
        XCTAssertTrue(app.navigationBars["Настройки"].staticTexts["Настройки"].exists)
                        
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.staticTexts["FaceID/TouchID"].exists)
        XCTAssertFalse((tablesQuery.cells.containing(.staticText, identifier: "FaceID/TouchID").switches.element.value as? String) == "1")
        XCTAssertTrue(tablesQuery.staticTexts["Скрыть профиль из поиска"].exists)
        XCTAssertFalse((tablesQuery.cells.containing(.staticText, identifier: "Скрыть профиль из поиска").switches.element.value as? String) == "1")
        XCTAssertTrue(app.buttons["Выйти"].exists)
    }
    
    func testSettingsBioAuth() throws {
        UserDefaults.standard.synchronize()
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 1).tap()
        app.tables.cells.containing(.staticText, identifier: "FaceID/TouchID").switches.element.tap()
        XCTAssertTrue((app.tables.cells.containing(.staticText, identifier: "FaceID/TouchID").switches.element.value as? String) == "1")
        app.tables.cells.containing(.staticText, identifier: "FaceID/TouchID").switches.element.tap()
        
        let elementsQuery = XCUIApplication().alerts["Отключить FaceID/TouchID?"].scrollViews.otherElements
        XCTAssertTrue(elementsQuery.staticTexts["Отключить FaceID/TouchID?"].exists)
        elementsQuery.buttons["Ок"].tap()
    }
    
    func testSettingsHidden() throws {
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 0).tap()
        app.buttons["Лента"].waitForExistence(timeout: 3)
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        app.tables.cells.containing(.staticText, identifier:"title 9").staticTexts["Test Name3"].tap()
        XCTAssertFalse(app.navigationBars["test1"].children(matching: .button).element(boundBy: 1).exists)
    }
    
    func testSettingsExit() throws {
        app.navigationBars["test1"].children(matching: .button).element(boundBy: 1).tap()
        app.buttons["Выйти"].tap()
        let elementsQuery = XCUIApplication().alerts["Подтвердите выход"].scrollViews.otherElements
        XCTAssertTrue(elementsQuery.staticTexts["Подтвердите выход"].exists)
        elementsQuery.buttons["Выйти"].tap()
        XCTAssertTrue(app.navigationBars["Авторизация"].waitForExistence(timeout: 5))
    }
}
