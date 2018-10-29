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
        
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        XCTAssertEqual(app.tables.switches["BlockerToggle.enableSearchSuggestions"].value as! String, targetValue)
    }
    
    func typeInURLBar() {
        app.textFields["Search or enter address"].tap()
        app.textFields["Search or enter address"].typeText("mozilla")
    }
    
    func testEnableHidesPrompt() {
        // Check search suggestions toggle is OFF
        checkToggle(isOn: false)
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar()

        // Prompt should display
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])

        // Press enable
        app.buttons["SearchSuggestionsPromptView.enableButton"].tap()

        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])

        // Check search suggestions toggle is ON
        app.buttons["URLBar.cancelButton"].tap()
        checkToggle(isOn: true)
    }
    
    func testDisableHidesPrompt() {
        // Check search suggestions toggle is OFF
        checkToggle(isOn: false)
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar()
        
        // Prompt should display
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Press disable
        app.buttons["SearchSuggestionsPromptView.disableButton"].tap()
        
        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Ensure search suggestions toggle is OFF in settings
        app.buttons["URLBar.cancelButton"].tap()
        checkToggle(isOn: false)
    }
    
    func testEnableToggleHidesPrompt() {
        // Check search suggestions toggle is OFF
        checkToggle(isOn: false)
        
        // Turn toggle ON
        let toggle = app.tables.switches["BlockerToggle.enableSearchSuggestions"]
        toggle.tap()
        
        // Prompt should not display
        app.buttons["SettingsViewController.doneButton"].tap()
        typeInURLBar()
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
    }
}
