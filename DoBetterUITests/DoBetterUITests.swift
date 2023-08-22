//
//  DoBetterUITests.swift
//  DoBetterUITests
//
//  Created by Никита Шестаков on 27.04.2023.
//

import XCTest

final class DoBetterSignInUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["test", "signIn"]
        app.launch()
        continueAfterFailure = false
    }

    func testUnregisteredEmailSignIn() throws {
        let tablesQuery = app.tables
        let emailTextField = tablesQuery.textFields["Введите почту"]
        emailTextField.tap()
        emailTextField.typeText("incorrect@unknown.ios")

        let secureTextField = tablesQuery.textFields["Введите пароль"]
        secureTextField.tap()
        secureTextField.typeText("12345678")
        tablesQuery.buttons["Войти"].tap()
        
        XCTAssertTrue(app.staticTexts["Пользователь не найден. Попробуйте зарегистрироваться!"].exists)
    }
    
    func testRegisteredEmailSignIn() throws {
        let tablesQuery = app.tables
        let emailTextField = tablesQuery.textFields["Введите почту"]
        emailTextField.tap()
        emailTextField.typeText("rikine@vk.com")

        let secureTextField = tablesQuery.textFields["Введите пароль"]
        secureTextField.tap()
        secureTextField.typeText("12345678")
        tablesQuery.buttons["Войти"].tap()
        
        XCTAssertTrue(app.staticTexts["Включить FaceID/TouchID?"].waitForExistence(timeout: 10))
    }
    
    func testWrongEnterEmailSignIn() throws {
        let tablesQuery = app.tables
        let emailTextField = tablesQuery.textFields["Введите почту"]
        emailTextField.tap()
        emailTextField.typeText("lalala")
        
        let secureTextField = tablesQuery.textFields["Введите пароль"]
        secureTextField.tap()
        secureTextField.typeText("1234")
        
        let button = tablesQuery/*@START_MENU_TOKEN@*/.buttons["Войти"]/*[[".cells.buttons[\"Войти\"]",".buttons[\"Войти\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        button.tap()

        XCTAssertTrue(app.staticTexts["Некорректная почта"].exists)
    }
    
    func testUnregisteredPhoneSignIn() throws {
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["С номером телефона"]/*[[".cells",".buttons[\"С номером телефона\"].staticTexts[\"С номером телефона\"]",".staticTexts[\"С номером телефона\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let phoneTextField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Введите номер телефона"]/*[[".cells.textFields[\"Введите номер телефона\"]",".textFields[\"Введите номер телефона\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        phoneTextField.tap()
        phoneTextField.typeText("9999999999")
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Войти"]/*[[".cells.buttons[\"Войти\"]",".buttons[\"Войти\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertTrue(app.staticTexts["Некорректный номер телефона"].exists)
    }
    
    func testWrongPhoneSignIn() throws {
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["С номером телефона"]/*[[".cells",".buttons[\"С номером телефона\"].staticTexts[\"С номером телефона\"]",".staticTexts[\"С номером телефона\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let phoneTextField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Введите номер телефона"]/*[[".cells.textFields[\"Введите номер телефона\"]",".textFields[\"Введите номер телефона\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        phoneTextField.tap()
        phoneTextField.typeText("2344325251")
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Войти"]/*[[".cells.buttons[\"Войти\"]",".buttons[\"Войти\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertTrue(app.staticTexts["Телефон ещё не зарегистрирован. Пожалуйста, зарегистрируйтесь"].exists)
    }
    
    func testRegisteredPhoneSignIn() throws {
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["С номером телефона"]/*[[".cells",".buttons[\"С номером телефона\"].staticTexts[\"С номером телефона\"]",".staticTexts[\"С номером телефона\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let phoneTextField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Введите номер телефона"]/*[[".cells.textFields[\"Введите номер телефона\"]",".textFields[\"Введите номер телефона\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        phoneTextField.tap()
        phoneTextField.typeText("2345678900")
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Войти"]/*[[".cells.buttons[\"Войти\"]",".buttons[\"Войти\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssertTrue(app.staticTexts["Готово"].waitForExistence(timeout: 10)
                      || app.staticTexts["Ввод кода"].waitForExistence(timeout: 10), app.staticTexts.allElementsBoundByAccessibilityElement.description)
    }
    
    func testGoogleSignIn() throws {
        let googleStaticText = app.tables/*@START_MENU_TOKEN@*/.staticTexts["Через Google"]/*[[".cells",".buttons[\"Через Google\"].staticTexts[\"Через Google\"]",".staticTexts[\"Через Google\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        googleStaticText.tap()
        googleStaticText.tap()
        app.webViews.staticTexts["nikitos3046@gmail.com"].tap()
        app.alerts["Включить FaceID/TouchID?"].scrollViews.otherElements.buttons["Ок"].tap()
    }
    
    func testWrongGoogleSignIn() throws {
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Через Google"]/*[[".cells.buttons[\"Через Google\"]",".buttons[\"Через Google\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Через Google"]/*[[".cells.buttons[\"Через Google\"]",".buttons[\"Через Google\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertTrue(app.buttons["Отменить"].waitForExistence(timeout: 10))
        app.buttons["Отменить"].tap()
    }
}
