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
//        waitforHittable(element: app.buttons["Settings"])
//        app.buttons["Settings"].tap()
//        app.tables.switches["BlockerToggle.enableSearchSuggestions"].tap()
        
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
    
    func checkSuggestions() {
        // Typing in URL bar should show search suggestions
        //waitforExistence(element: app.textFields["Search or enter address"])
        //typeInURLBar(text: "g")
        
        // Check search cells are displayed correctly
        let firstSuggestion = app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 0)
        let secondSuggestion = app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 1)
        let thirdSuggestion = app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 2)
        let fourthSuggestion = app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 3)
        
        waitforExistence(element: firstSuggestion)
        waitforExistence(element: secondSuggestion)
        waitforExistence(element: thirdSuggestion)
        waitforExistence(element: fourthSuggestion)
        
        XCTAssertEqual("g", firstSuggestion.label)
        XCTAssertEqual("gmail", secondSuggestion.label)
        XCTAssertEqual("google", thirdSuggestion.label)
        XCTAssertEqual("google maps", fourthSuggestion.label)
        
        // Tap on first suggestion
        firstSuggestion.tap()
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "www.google.com")
    }
    
    func testEnableThroughPrompt() {
        // Check search suggestions toggle is OFF
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        checkToggle(isOn: false)
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar(text: "g")

        // Prompt should display
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])

        // Press enable
        app.buttons["SearchSuggestionsPromptView.enableButton"].tap()

        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Ensure search suggestions are shown
        checkSuggestions()

        // Check search suggestions toggle is ON
        waitforHittable(element: app.buttons["HomeView.settingsButton"])
        app.buttons["HomeView.settingsButton"].tap()
        checkToggle(isOn: true)
    }
    
    func testDisableThroughPrompt() {
        // Check search suggestions toggle is OFF
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        checkToggle(isOn: false)
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar(text: "g")
        
        // Prompt should display
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Press disable
        app.buttons["SearchSuggestionsPromptView.disableButton"].tap()
        
        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Ensure only one search cell is shown
        let suggestion = app.buttons.matching(identifier: "OverlayView.searchButton").element(boundBy: 0)
        waitforExistence(element: suggestion)
        XCTAssertEqual("Search for g", suggestion.label)
       
        // Tap on suggestion
        suggestion.tap()
        waitForValueContains(element: app.textFields["URLBar.urlText"], value: "www.google.com")
        
        // Check search suggestions toggle is OFF
        waitforHittable(element: app.buttons["HomeView.settingsButton"])
        app.buttons["HomeView.settingsButton"].tap()
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
    }
    
}
