//
//  DoBetterPinCodeEnterUITests.swift
//  DoBetterUITests
//
//  Created by Никита Шестаков on 30.04.2023.
//

import XCTest

final class DoBetterMainTabUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["test", "mainTab"]
        app.launch()
    }

    func test2Tabs() throws {
        let tabBar = app.tabBars["Панель вкладок"]
        XCTAssertTrue(tabBar.buttons["Моя лента"].exists)
        XCTAssertTrue(tabBar.buttons["Лента"].exists)
    }
    
    func testNavBar() throws {
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        XCTAssertTrue(app.navigationBars["Лента подписок"].staticTexts["Лента подписок"].exists)
        XCTAssertTrue(app.navigationBars["Лента подписок"].children(matching: .button).element(boundBy: 0).exists)
        app.tabBars["Панель вкладок"].buttons["Моя лента"].tap()
        XCTAssertTrue(app.navigationBars["Моя лента"].children(matching: .button).element(boundBy: 0).exists)
    }
    
    func testFilters() throws {
        XCTAssertTrue(app.staticTexts["Фильтры"].exists)
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        XCTAssertTrue(app.staticTexts["Фильтры"].exists)
    }
    
    func testCreateTaskButton() throws {
        XCTAssertTrue(app.images["CreateTask"].exists)
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        XCTAssertFalse(app.images["CreateTask"].exists)
    }
    
    func testSearchTasks() throws {
        let textField = app.tables.textFields["Поиск задачи по названию"]
        textField.tap()
        textField.typeText("hello")
        XCTAssertFalse(app.tableRows.cells.allElementsBoundByAccessibilityElement.count > 1, app.tableRows.cells.allElementsBoundByIndex.description)
    }
    
    func testLikeTasks() throws {
        let tablesQuery = app.tables
        let title3CellsQuery = tablesQuery.cells.containing(.staticText, identifier:"title3")
        let button = title3CellsQuery.children(matching: .button).element(boundBy: 0)
        button.tap()
        button.tap()
        app.navigationBars["Задача"].buttons["Моя лента"].tap()
        
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        
        let button2 = tablesQuery.cells.containing(.staticText, identifier:"Test Name2").children(matching: .button).element(boundBy: 0)
        button2.tap()
        button2.tap()
        
        app.navigationBars["Задача"].children(matching: .button).element(boundBy: 2).tap()
    }
    
    func testDoneTasks() throws {
        let tablesQuery = app.tables
        let button = tablesQuery.cells.containing(.staticText, identifier:"title2").children(matching: .button).element(boundBy: 1)
        button.tap()
        button.tap()
        app.navigationBars["Задача"].buttons["Моя лента"].tap()
        
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        
        let button2 = tablesQuery.cells.containing(.staticText, identifier:"Test Name2").children(matching: .button).element(boundBy: 1)
        button2.tap()
        button2.tap()
        
        XCTAssertFalse(app.navigationBars["Задача"].children(matching: .button).element(boundBy: 2).exists)
    }
    
    func testTasks() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["title1"].tap()
        
        let button = app.navigationBars["Задача"].buttons["Моя лента"]
        button.tap()
        tablesQuery.staticTexts["description 1"].tap()
        button.tap()
        
        let title1CellsQuery = tablesQuery.cells.containing(.staticText, identifier:"title1")
        title1CellsQuery.staticTexts["28.09.1939 10:04"].tap()
        button.tap()
        
        title1CellsQuery.staticTexts["Test Name1"].tap()
        
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(app.tables.cells.containing(.staticText, identifier: "title 13").element.exists)
        
        app.swipeDown()
        app.swipeDown()
        
        title1CellsQuery.element.tap()
        
        app.navigationBars["Задача"].buttons["Моя лента"].tap()
        
        app.tabBars["Панель вкладок"].buttons["Лента"].tap()
        
        app.tables.cells.containing(.staticText, identifier:"title 10").staticTexts["Test Name3"].tap()
        app.navigationBars["test3"].children(matching: .button).element(boundBy: 0).tap()
        
        app.tables.cells.containing(.staticText, identifier:"title 10").element.tap()
        app.navigationBars["Задача"].children(matching: .button).element(boundBy: 2).tap()
    }
    
    func testFiltersParameters() throws {
        app.staticTexts["Фильтры"].tap()
        app.tables.staticTexts["Только готовые задачи"].waitForExistence(timeout: 5)
        app.tables.staticTexts["Только готовые задачи"].tap()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Очистить"].tap()
        tablesQuery.staticTexts["Выберите минимальную дату создания"].tap()
        
        let staticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Выберите максимальную дату создания"]/*[[".cells.staticTexts[\"Выберите максимальную дату создания\"]",".staticTexts[\"Выберите максимальную дату создания\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText.tap()
        
        staticText.tap()
        
        let pickerWheel = app.datePickers/*@START_MENU_TOKEN@*/.pickerWheels["Апреля"]/*[[".pickers.pickerWheels[\"Апреля\"]",".pickerWheels[\"Апреля\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        let staticText3 = app.staticTexts["Готово"]
        staticText3.tap()
        tablesQuery.cells.containing(.staticText, identifier:"Выберите максимальную дату создания").element.tap()
        staticText3.tap()
        
        let staticText4 = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["работа"]/*[[".cells.staticTexts[\"работа\"]",".staticTexts[\"работа\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText4.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["отсутствует"]/*[[".cells.staticTexts[\"отсутствует\"]",".staticTexts[\"отсутствует\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let staticText5 = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Только задачи в процессе"]/*[[".cells.staticTexts[\"Только задачи в процессе\"]",".staticTexts[\"Только задачи в процессе\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText5.tap()
        
        let staticText6 = tablesQuery.staticTexts["Только готовые задачи"]
        staticText6.tap()
        staticText5.tap()
        app.buttons["Сохранить"].tap()
    }
}

extension XCUIApplication {
    func dismissKeyboardIfPresent() {
        if keyboards.element(boundBy: 0).exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                keyboards.buttons["Hide keyboard"].tap()
            } else {
                toolbars.buttons["Done"].tap()
            }
        }
    }
}
