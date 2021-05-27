/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */
 
import Foundation
import XCTest

class BasicBrowsing: BaseTestCase {

    // Smoke test
    func testLaunchExternalApp() {
        // Load URL
        loadWebPage("https://www.example.com")
        waitForWebPageLoad()

        // Tap on Page Action button
        waitforExistence(element: app.buttons["URLBar.pageActionsButton"])
        app.buttons["URLBar.pageActionsButton"].tap()

        // Tap Share button
        let ShareButton = app.cells["Share Page With..."]
        waitforExistence(element: ShareButton)
        ShareButton.tap()

        // Launch external app
        let RemindersApp = app.cells["Reminders"]
        waitforExistence(element: RemindersApp)
        RemindersApp.tap()
        waitforExistence(element: app.buttons["Add"])
        XCTAssertTrue(app.buttons["Add"].exists)
    }
    
    // Smoke test
    func testAdBlocking() {
        // Load URL
        loadWebPage("https://blockads.fivefilters.org/")
        waitForWebPageLoad()

        // Check ad blocking is enabled
        let TrackingProtection = app.staticTexts["Ad blocking enabled!"]
        XCTAssertTrue(TrackingProtection.exists)
    }
}
