import XCTest

final class LoginFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testLoginButtonRequiresValidCredentials() {
        app.launch(scenario: "-ui-testing-login-success")

        let email = app.element(identifier: "login_email_textfield")
        let password = app.element(identifier: "login_password_securefield")
        let loginButton = app.element(identifier: "login_button")

        XCTAssertTrue(email.waitForExistence(timeout: 3))
        XCTAssertFalse(loginButton.isEnabled)

        email.tap()
        email.typeText("teste@teste.com")
        password.tap()
        password.typeText("123456")

        XCTAssertTrue(loginButton.isEnabled)
    }

    func testPasswordVisibilityCanBeToggled() {
        app.launch(scenario: "-ui-testing-login-success")

        let visibilityButton = app.element(identifier: "login_password_visibility_button")

        XCTAssertTrue(visibilityButton.waitForExistence(timeout: 3))
        XCTAssertEqual(visibilityButton.label, "Exibir senha")

        visibilityButton.tap()

        XCTAssertEqual(visibilityButton.label, "Ocultar senha")
    }

    func testSuccessfulLoginNavigatesToHome() {
        app.launch(scenario: "-ui-testing-login-success")

        fillCredentials()
        app.element(identifier: "login_button").tap()

        XCTAssertTrue(app.element(identifier: "home_map").waitForExistence(timeout: 5))
        XCTAssertTrue(app.element(identifier: "home_logout_button").exists)
    }

    func testFailedLoginDisplaysErrorAndStaysOnLogin() {
        app.launch(scenario: "-ui-testing-login-failure")

        fillCredentials()
        app.element(identifier: "login_button").tap()

        XCTAssertTrue(app.element(identifier: "login_error_text").waitForExistence(timeout: 3))
        XCTAssertTrue(app.element(identifier: "login_button").exists)
        XCTAssertFalse(app.element(identifier: "home_map").exists)
    }

    func testEnglishLocalizationDisplaysTranslatedLoginContent() {
        app.launch(scenario: "-ui-testing-login-success", language: "en")

        XCTAssertTrue(app.staticTexts["My Location"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Welcome"].exists)
        XCTAssertTrue(app.buttons["Sign in"].exists)
    }

    private func fillCredentials() {
        let email = app.element(identifier: "login_email_textfield")
        let password = app.element(identifier: "login_password_securefield")

        XCTAssertTrue(email.waitForExistence(timeout: 3))
        email.tap()
        email.typeText("teste@teste.com")
        password.tap()
        password.typeText("123456")
    }
}
