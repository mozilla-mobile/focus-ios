/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class OnboardingTest: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    // Copied from BaseTestCase
    private func waitForExistence(_ element: XCUIElement, timeout: TimeInterval = 5.0, file: String = #file, line: UInt = #line) {
        waitFor(element, with: "exists == true", timeout: timeout, file: file, line: line)
    }

    private func waitFor(_ element: XCUIElement, with predicateString: String, description: String? = nil, timeout: TimeInterval = 5.0, file: String, line: UInt) {
           let predicate = NSPredicate(format: predicateString)
           let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
           let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
           if result != .completed {
               let message = description ?? "Expect predicate \(predicateString) for \(element.description)"
               var issue = XCTIssue(type: .assertionFailure, compactDescription: message)
               let location = XCTSourceCodeLocation(filePath: file, lineNumber: Int(line))
               issue.sourceCodeContext = XCTSourceCodeContext(location: location)
               self.record(issue)
           }
       }

}
