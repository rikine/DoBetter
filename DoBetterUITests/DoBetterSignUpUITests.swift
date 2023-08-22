//
//  DoBetterSignUpUITests.swift
//  DoBetterUITests
//
//  Created by Никита Шестаков on 30.04.2023.
//

import XCTest

final class DoBetterSignUpUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments = ["test", "signIn"]
        app.launch()
        continueAfterFailure = false
    }

    func testEmailSignUp() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Все ещё нет аккаунта? Зарегистрируйтесь"].tap()
        
        let loginField = tablesQuery/*@START_MENU_TOKEN@*/.textFields["Введите логин"]/*[[".cells.textFields[\"Введите логин\"]",".textFields[\"Введите логин\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        loginField.tap()
        loginField.typeText("test1")
        
        let textField = tablesQuery.textFields["Введите почту"]
        textField.tap()
        textField.typeText("test1@vk.com")
        
        let secureTextField = tablesQuery.textFields["Введите пароль"]
        let secureTextField2 = tablesQuery.textFields["Введите пароль ещё раз..."]
        secureTextField.tap()
        secureTextField.typeText("12345678")
        
        secureTextField2.tap()
        secureTextField2.typeText("12345678")
        
        tablesQuery.buttons["Войти"].tap()
        XCTAssertTrue(app.alerts["Включить FaceID/TouchID?"].scrollViews.otherElements.buttons["Ок"].exists)
    }
    
    func testWrongEmailSignUp() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Все ещё нет аккаунта? Зарегистрируйтесь"].tap()
        
        let button = tablesQuery.buttons["Войти"]
        button.tap()

        XCTAssertTrue(app.staticTexts["Заполните все поля"].exists)
        
        let loginField = tablesQuery.textFields["Введите логин"]
        loginField.tap()
        loginField.typeText("rikine12")
        
        let emailField = tablesQuery.textFields["Введите почту"]
        emailField.tap()
        emailField.typeText("rikine12@vk.com")
        
        let passwordField = tablesQuery.textFields["Введите пароль"]
        passwordField.tap()
        passwordField.typeText("12345678")
        
        let reenterField = tablesQuery.textFields["Введите пароль ещё раз..."]
        reenterField.tap()
        reenterField.typeText("1234567")
        
        button.tap()
        
        XCTAssertTrue(app.staticTexts["Пароль должны быть одинаковыми"].exists)
    }
    
    func testRegisteredEmailSignUp() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Все ещё нет аккаунта? Зарегистрируйтесь"].tap()
        
        let loginField = tablesQuery.textFields["Введите логин"]
        loginField.tap()
        loginField.typeText("test")
        
        let textField = tablesQuery.textFields["Введите почту"]
        textField.tap()
        textField.typeText("test@vk.com")
        
        let secureTextField = tablesQuery.textFields["Введите пароль"]
        secureTextField.tap()
        secureTextField.typeText("12345678")
        
        let secureTextField2 = tablesQuery.textFields["Введите пароль ещё раз..."]
        secureTextField2.tap()
        secureTextField2.typeText("12345678")
        
        tablesQuery.buttons["Войти"].tap()
        XCTAssertTrue(app.staticTexts["Логин существует, попробуйте другой"].exists)
    }
    
    func testPhoneSignUp() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Все ещё нет аккаунта? Зарегистрируйтесь"].tap()
        tablesQuery.buttons["С номером телефона"].tap()
        
        let textField = tablesQuery.textFields["Введите логин"]
        textField.tap()
        textField.typeText("test")
        
        let textField2 = tablesQuery.textFields["Введите номер телефона"]
        textField2.tap()
        textField2.typeText("2345678900")
        
        let button = tablesQuery.buttons["Войти"]
        button.tap()
        app.staticTexts["Логин существует, попробуйте другой"].tap()
        
        textField.tap()
        textField.typeText("1")
        button.tap()
        app.staticTexts["Телефон уже зарегистрирован. Пожалуйста, авторизуйтесь"].tap()
    }
    
    func testWrongPhoneSignUp() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Все ещё нет аккаунта? Зарегистрируйтесь"].tap()
        tablesQuery.buttons["С номером телефона"].tap()
        
        let textField = tablesQuery.textFields["Введите логин"]
        textField.tap()
        textField.typeText("test1")
        
        let textField2 = tablesQuery.textFields["Введите номер телефона"]
        textField2.tap()
        textField2.typeText("234567890012")
        
        let button = tablesQuery.buttons["Войти"]
        button.tap()
        XCTAssertTrue(app.staticTexts["Некорректный номер телефона"].exists)
    }
    
    func testMoveToSignIn() throws {
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Все ещё нет аккаунта? Зарегистрируйтесь"].tap()
        tablesQuery.staticTexts["Уже есть аккаунт? Авторизируйтесь"].tap()
        XCTAssertTrue(app.staticTexts["Авторизация"].exists)
    }
}
