//
//  DoBetterTaskUITests.swift
//  DoBetterUITests
//
//  Created by Никита Шестаков on 30.04.2023.
//

import XCTest

final class DoBetterTaskUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["test", "mainTab"]
        app.launch()
        continueAfterFailure = false
    }

    func testShowingTasks() throws {
        app.tables.staticTexts["title1"].tap()
        
        XCTAssertTrue(app.tables.staticTexts["бизнес"].exists)
        XCTAssertTrue(app.tables.staticTexts["title1"].exists)
        XCTAssertTrue(app.tables.staticTexts["Осталось"].exists)
        XCTAssertTrue(app.tables.staticTexts["Создатель"].exists)
        XCTAssertTrue(app.tables.staticTexts["Просрочена"].exists)
        XCTAssertTrue(app.tables.staticTexts["Описание"].exists)
        XCTAssertTrue(app.tables.staticTexts["description 1"].exists)
        XCTAssertTrue(app.tables.staticTexts["Создана В"].exists)
        XCTAssertTrue(app.tables.staticTexts["01.01.1939 03:20"].exists)
        XCTAssertTrue(app.staticTexts["Новая"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["0"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Отметить как В Процессе"].exists)
        app.staticTexts["Отметить как В Процессе"].swipeRight()
        
        let tablesQuery = app.tables
        let navigationBar = app.navigationBars["Задача"]
        let button = navigationBar.children(matching: .button).element(boundBy: 1)
        button.tap()
        
        let staticText = tablesQuery.staticTexts["Изменить задачу"]
        staticText.swipeRight()
        staticText.swipeDown()
        app.otherElements["Close"].children(matching: .other).element(boundBy: 0).tap()
        navigationBar.children(matching: .button).element(boundBy: 2).tap()
    }
    
    func testCreateTask() throws {
        app.images["CreateTask"].tap()
        let tablesQuery = app.tables
        let textField = tablesQuery.textFields["Введите название"]
        textField.tap()
        textField.typeText("Title")
        
        let textView = tablesQuery.cells.containing(.staticText, identifier:"Описание задачи").children(matching: .textView).element
        textView.tap()
        tablesQuery.staticTexts["00.00.0000 00:00"].tap()
        app.datePickers.pickerWheels["Сегодня"].press(forDuration: 1.6);
        app.staticTexts["Готово"].tap()
        
        let collectionViewsQuery = tablesQuery.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        
        let element = collectionViewsQuery.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 7).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        element.tap()
        tablesQuery.staticTexts["дом"].tap()
        tablesQuery.staticTexts["Загрузить фото"].tap()
        app.scrollViews.otherElements.buttons["Cancel"].tap()
        app.staticTexts["Сохранить"].tap()
    }
    
    func testWrongCreateOrUpdateTask() throws {
        app.images["CreateTask"].tap()
        XCTAssertTrue(app.buttons["Сохранить"].waitForExistence(timeout: 10))
        app.buttons["Сохранить"].tap()
        XCTAssertTrue(app.staticTexts["Empty title"].exists)
    }
    
    func testChangeTask() throws {
        app.tables.staticTexts["title1"].tap()
        let button = app.navigationBars["Задача"].children(matching: .button).element(boundBy: 1)
        button.tap()
        
        let tablesQuery = app.tables
        let titleField = tablesQuery.textFields["Введите название"]
        titleField.tap()
        titleField.typeText("NEW")
        
        let textView = tablesQuery.cells.containing(.staticText, identifier:"Описание задачи").children(matching: .textView).element
        textView.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.collectionViews/*[[".cells.collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .cell).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        app.staticTexts["Сохранить"].tap()
    }
}
