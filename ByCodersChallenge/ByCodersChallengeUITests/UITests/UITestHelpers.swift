import XCTest

extension XCUIApplication {
    func launch(scenario: String, language: String = "pt-BR") {
        launchArguments = [
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", language,
            scenario
        ]
        launch()
    }

    func element(identifier: String) -> XCUIElement {
        descendants(matching: .any)[identifier]
    }
}
