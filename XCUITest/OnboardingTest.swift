//
//  OnboardingTest.swift
//  XCUITest
//
//  Created by Sawyer Blatz on 5/30/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import XCTest

class OnboardingTest: BaseTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    func testPressingDots() {
        let stackElement = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2)
        
        let pageIndicatorButton1 = stackElement.children(matching: .button).matching(identifier: "page indicator").element(boundBy: 0)
        let pageIndicatorButton2 = stackElement.children(matching: .button).matching(identifier: "page indicator").element(boundBy: 1)
        let pageIndicatorButton3 = stackElement.children(matching: .button).matching(identifier: "page indicator").element(boundBy: 2)

        waitforExistence(element: app.staticTexts["Power up your privacy"])
        
        pageIndicatorButton2.tap()
        waitforExistence(element: app.staticTexts["Your search, your way"])
        XCTAssert(pageIndicatorButton2.isSelected)

        pageIndicatorButton3.tap()
        waitforExistence(element: app.staticTexts["Your history is history"])
        XCTAssert(pageIndicatorButton3.isSelected)

        pageIndicatorButton1.tap()
        waitforExistence(element: app.staticTexts["Your search, your way"])
        XCTAssert(pageIndicatorButton2.isSelected)

        pageIndicatorButton1.tap()
        waitforExistence(element: app.staticTexts["Power up your privacy"])
        XCTAssert(pageIndicatorButton1.isSelected)
        XCTAssert(!pageIndicatorButton2.isSelected)
        
        // Make sure button alpha values update even when selecting "Next" button
        let nextButton = app.buttons["Next"]
        nextButton.tap()
        waitforExistence(element: app.staticTexts["Your search, your way"])
        XCTAssert(pageIndicatorButton2.isSelected)
    }
    
    
}
