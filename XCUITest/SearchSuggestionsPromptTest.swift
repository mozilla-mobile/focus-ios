//
//  SearchSuggestionsPromptTest.swift
//  XCUITest
//
//  Created by Janice Lee on 2018-10-24.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import XCTest

class SearchSuggestionsPromptTest: BaseTestCase {
    
    override func setUp() {
        super.setUp()
        dismissFirstRunUI()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    func checkToggle(isOn: Bool) {
        let targetValue = isOn ? "1" : "0"
        XCTAssertEqual(app.tables.switches["BlockerToggle.enableSearchSuggestions"].value as! String, targetValue)
    }
    
    func typeInURLBar(text: String) {
        app.textFields["Search or enter address"].tap()
        app.textFields["Search or enter address"].typeText(text)
    }
    
    func testEnableHidesPrompt() {
        // Check search suggestions toggle is OFF
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        checkToggle(isOn: false)
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar(text: "mozilla")

        // Prompt should display
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])

        // Press enable
        app.buttons["SearchSuggestionsPromptView.enableButton"].tap()

        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])

        // Check search suggestions toggle is ON
        app.buttons["URLBar.cancelButton"].tap()
        app.buttons["Settings"].tap()
        checkToggle(isOn: true)
    }
    
    func testDisableHidesPrompt() {
        // Check search suggestions toggle is OFF
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        checkToggle(isOn: false)
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar(text: "mozilla")
        
        // Prompt should display
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Press disable
        app.buttons["SearchSuggestionsPromptView.disableButton"].tap()
        
        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Ensure search suggestions toggle is OFF in settings
        app.buttons["URLBar.cancelButton"].tap()
        app.buttons["Settings"].tap()
        checkToggle(isOn: false)
    }
    
    func testEnableToggleHidesPrompt() {
        // Check search suggestions toggle is OFF
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        checkToggle(isOn: false)
        
        // Turn toggle ON
        let toggle = app.tables.switches["BlockerToggle.enableSearchSuggestions"]
        toggle.tap()
        
        // Prompt should not display
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar(text: "mozilla")
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
    }
    
    func testDisplaysRetrievedSuggestions() {
        // Turn on search suggestions
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        app.tables.switches["BlockerToggle.enableSearchSuggestions"].tap()
        app.buttons["SettingsViewController.doneButton"].tap()
        
        // Typing in URL bar should show search suggestions
        waitforExistence(element: app.textFields["Search or enter address"])
        typeInURLBar(text: "g")
        
        // Check search cells are displayed correctly
        let firstSuggestion = app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 0)
        waitforExistence(element: app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 1))
        waitforExistence(element: app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 2))
        waitforExistence(element: app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 3))
        
        // Tap on first suggestion
        firstSuggestion.tap()
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "https://www.google.ca/search?q=g&rlz=1C5CHFA_enCA703CA703&oq=g&aqs=chrome..69i57j69i60l5.573j0j4&sourceid=chrome&ie=UTF-8")
    }
    
}
