import XCTest

final class HomeFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testRestoredSessionLoadsHomeAndMap() {
        app.launch(scenario: "-ui-testing-home-success")

        XCTAssertTrue(app.element(identifier: "home_map").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Usuário UI Test"].exists)
    }

    func testPermissionDeniedExplainsUsageAndShowsSettingsAction() {
        app.launch(scenario: "-ui-testing-home-permission-denied")

        XCTAssertTrue(app.staticTexts["Precisamos da sua localização"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Mostrar sua posição"].exists)
        XCTAssertTrue(app.staticTexts["Salvar a última localização"].exists)
        XCTAssertTrue(app.staticTexts["Respeitar sua privacidade"].exists)
        XCTAssertTrue(app.element(identifier: "home_open_settings_button").exists)
    }

    func testLocationFailureShowsErrorAndRetryAction() {
        app.launch(scenario: "-ui-testing-home-failure")

        XCTAssertTrue(app.element(identifier: "home_error").waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Tentar novamente"].exists)
    }

    func testStaleLocationFromPermissionDeniedShowsMapWithSettingsBannerAction() {
        app.launch(scenario: "-ui-testing-home-stale-permission-denied")

        XCTAssertTrue(app.element(identifier: "home_map").waitForExistence(timeout: 5))
        XCTAssertTrue(app.element(identifier: "home_stale_location_banner").waitForExistence(timeout: 2))
        XCTAssertTrue(app.element(identifier: "home_stale_open_settings_button").waitForExistence(timeout: 2))
        XCTAssertFalse(app.element(identifier: "home_stale_retry_button").exists)
        XCTAssertFalse(app.element(identifier: "home_open_settings_button").exists)
    }

    func testStaleLocationFromUnavailableShowsMapWithRetryBannerAction() {
        app.launch(scenario: "-ui-testing-home-stale-unavailable")

        XCTAssertTrue(app.element(identifier: "home_map").waitForExistence(timeout: 5))
        XCTAssertTrue(app.element(identifier: "home_stale_location_banner").waitForExistence(timeout: 2))
        XCTAssertTrue(app.element(identifier: "home_stale_retry_button").waitForExistence(timeout: 2))
        XCTAssertFalse(app.element(identifier: "home_stale_open_settings_button").exists)
        XCTAssertFalse(app.element(identifier: "home_open_settings_button").exists)
    }

    func testLogoutReturnsToLogin() {
        app.launch(scenario: "-ui-testing-home-success")

        let logoutButton = app.element(identifier: "home_logout_button")
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let confirmLogout = app.sheets.buttons["Sair"]
        XCTAssertTrue(confirmLogout.waitForExistence(timeout: 3))
        confirmLogout.tap()

        XCTAssertTrue(app.element(identifier: "login_button").waitForExistence(timeout: 5))
    }
}
