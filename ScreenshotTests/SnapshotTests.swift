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
        app.buttons["IntroViewController.button"].tap()

        snapshot("01Home")

        snapshot("02LocationBarEmptyState")
        app.textFields["URLBar.urlText"].typeText("bugzilla.mozilla.org")
        snapshot("03SearchFor")

        app.typeText("\n")
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "https://bugzilla.mozilla.org/")
        
        app.textFields["URLBar.urlText"].typeText("bugzilla")
        app.buttons["FindInPageBar.button"].tap()
        
        snapshot("04FindInPage")
        
        snapshot("05EraseButton")

        app.buttons["URLBar.deleteButton"].tap()
        waitforExistence(element: app.staticTexts["Toast.label"])
        snapshot("06YourBrowsingHistoryHasBeenErased")
    }

    func test02Settings() {
        let app = XCUIApplication()
        app.buttons["HomeView.settingsButton"].tap()
        snapshot("07Settings")
        app.swipeUp()
        snapshot("08Settings")
        app.swipeDown()
        app.cells["SettingsViewController.searchCell"].tap()
        snapshot("09SettingsSearchEngine")
        app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()
        app.swipeUp()
        app.switches["BlockerToggle.BlockOther"].tap()
        snapshot("10SettingsBlockOtherContentTrackers")
    }
    
    func test03About() {
        let app = XCUIApplication()
        app.buttons["HomeView.settingsButton"].tap()
        app.cells["settingsViewController.about"].tap()
        snapshot("11About")
        app.swipeUp()
        snapshot("12About")
    }

    func test04ShareMenu() {
        let app = XCUIApplication()
        app.textFields["URLBar.urlText"].typeText("bugzilla.mozilla.org\n")
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "https://bugzilla.mozilla.org/")
        app.buttons["BrowserToolset.sendButton"].tap()
        snapshot("13ShareMenu")
    }

    func test05SafariIntegration() {
        let app = XCUIApplication()
        app.buttons["HomeView.settingsButton"].tap()
        app.tables.switches["BlockerToggle.Safari"].tap()
        snapshot("14SafariIntegrationInstructions")
    }

    func test06OpenMaps() {
        let app = XCUIApplication()
        app.textFields["URLBar.urlText"].typeText("maps.apple.com\n")
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "http://maps.apple.com")
        snapshot("15OpenMaps")
    }

    func test07OpenAppStore() {
        let app = XCUIApplication()
        app.textFields["URLBar.urlText"].typeText("itunes.apple.com\n")
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "http://itunes.apple.com")
        snapshot("16OpenAppStore")
    }

    func test08PasteAndGo() {
        let app = XCUIApplication()
        // Inject a string into clipboard
        let clipboardString = "Hello world"
        UIPasteboard.general.string = clipboardString

        // Enter 'mozilla' on the search field
        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]
        searchOrEnterAddressTextField.typeText("mozilla.org\n")

        // Check the correct site is reached
        waitForValueContains(element: searchOrEnterAddressTextField, value: "https://www.mozilla.org/")

        // Tap URL field, check for paste & go menu
        searchOrEnterAddressTextField.tap()
        searchOrEnterAddressTextField.coordinate(withNormalizedOffset: CGVector.zero).withOffset(CGVector(dx:10,dy:0)).press(forDuration: 1.5)
        expectation(for: NSPredicate(format: "count > 0"), evaluatedWith: app.menuItems, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        app.menuItems.element(boundBy: 3).tap()

        snapshot("08PasteAndGo")
    }
    
    func test09TrackingProtection() {
        let app = XCUIApplication()

        // Inject a string into clipboard
        let clipboardString = "Hello world"
        UIPasteboard.general.string = clipboardString

        // Enter 'mozilla' on the search field
        let searchOrEnterAddressTextField = app.textFields["URLBar.urlText"]
        searchOrEnterAddressTextField.typeText("mozilla.org\n")

        // Check the correct site is reached
        waitForValueContains(element: searchOrEnterAddressTextField, value: "https://www.mozilla.org/")
        app.otherElements["URLBar.trackingProtectionIcon"].tap()
        snapshot("09TrackingProtection")
    }
    
    func test10CustomSearchEngines() {
        let app = XCUIApplication()

        app.buttons["HomeView.settingsButton"].tap()
        app.cells["SettingsViewController.searchCell"].tap()
        app.cells["addSearchEngine"].tap()
        snapshot("10CustomSearchEngines")
    }
    
    func test11AutocompleteURLs() {
        let app = XCUIApplication()

        app.buttons["HomeView.settingsButton"].tap()
        app.cells["SettingsViewController.autocompleteCell"].tap()
        snapshot("11AutocompleteURLs")
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
