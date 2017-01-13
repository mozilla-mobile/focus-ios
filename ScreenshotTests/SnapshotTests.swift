/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class SnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func test01Screenshots() {
        let app = XCUIApplication()
        snapshot("00FirstRun")
        app.buttons["FirstRunViewController.button"].tap()

        snapshot("01Home")

        app.buttons["URLBar.activateButton"].tap()
        snapshot("02LocationBarEmptyState")
        app.textFields["URLBar.urlText"].typeText("people-mozilla.org")
        snapshot("03SearchFor")

        app.typeText("\n")
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "https://people-mozilla.org/")
        snapshot("04EraseButton")

        app.buttons["URLBar.deleteButton"].tap()
        waitforExistence(element: app.staticTexts["Toast.label"])
        snapshot("05YourBrowsingHistoryHasBeenErased")
    }

    func test02Settings() {
        let app = XCUIApplication()
        app.buttons["HomeView.settingsButton"].tap()
        snapshot("06Settings")
        app.swipeUp()
        snapshot("07Settings")
        app.swipeDown()
        app.cells["SettingsViewController.searchCell"].tap()
        snapshot("08SettingsSearchEngine")
        app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()
        app.swipeUp()
        app.switches["BlockerToggle.BlockOther"].tap()
        snapshot("09SettingsBlockOtherContentTrackers")
    }

    func test03About() {
        let app = XCUIApplication()
        app.buttons["HomeView.settingsButton"].tap()
        app.buttons["SettingsViewController.aboutButton"].tap()
        snapshot("10About")
        app.swipeUp()
        snapshot("11About")
    }

    func test04ShareMenu() {
        let app = XCUIApplication()
        app.buttons["URLBar.activateButton"].tap()
        app.textFields["URLBar.urlText"].typeText("people-mozilla.org\n")
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "https://people-mozilla.org/")
        app.buttons["BrowserToolset.sendButton"].tap()
        snapshot("12ShareMenu")
    }

    func test05SafariIntegration() {
        let app = XCUIApplication()
        app.buttons["HomeView.settingsButton"].tap()
        app.tables.switches["BlockerToggle.Safari"].tap()
        snapshot("13SafariIntegrationInstructions")
    }

    func waitForValueContains(element:XCUIElement, value:String, file: String = #file, line: UInt = #line) {
        let predicateText = "value CONTAINS " + "'" + value + "'"
        let valueCheck = NSPredicate(format: predicateText)

        expectation(for: valueCheck, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 20) {(error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after 20 seconds."
                self.recordFailure(withDescription: message,
                                   inFile: file, atLine: line, expected: true)
            }
        }
    }

    func waitforExistence(element: XCUIElement, file: String = #file, line: UInt = #line) {
        let exists = NSPredicate(format: "exists == true")

        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 20) {(error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after 20 seconds."
                self.recordFailure(withDescription: message,
                                   inFile: file, atLine: line, expected: true)
            }
        }
    }
}
