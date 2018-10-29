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
    
    func testEnableHidesPrompt() {
        // Check search suggestions toggle is OFF initially
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        let toggle = app.tables.switches["BlockerToggle.enableSearchSuggestions"]
        XCTAssertEqual(toggle.value as! String, "0")
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        app.textFields["Search or enter address"].tap()
        app.textFields["Search or enter address"].typeText("mozilla")

        // Ensure that prompt shows
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])

        // Press enable
        app.buttons["SearchSuggestionsPromptView.enableButton"].tap()

        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // 
        XCTAssertTrue(UserDefaults.standard.bool(forKey: SearchSuggestionsPromptView.respondedToSearchSuggestionsPrompt))

        // Check search suggestions toggle is OFF in settings
        app.buttons["URLBar.cancelButton"].tap()
        app.buttons["Settings"].tap()
        XCTAssertEqual(toggle.value as! String, "1")
    }
    
    func testDisableHidesPrompt() {
        // Ensure search suggestions toggle is OFF initially
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        let toggle = app.tables.switches["BlockerToggle.enableSearchSuggestions"]
        XCTAssertEqual(toggle.value as! String, "0")
        
        // Activate prompt by typing in URL bar
        app.buttons["SettingsViewController.doneButton"].tap()
        app.textFields["Search or enter address"].tap()
        app.textFields["Search or enter address"].typeText("mozilla")
        
        // Ensure prompt shows
        waitforExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Press disable
        app.buttons["SearchSuggestionsPromptView.disableButton"].tap()
        
        // Ensure prompt disappears
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
        
        // Ensure search suggestions toggle is OFF in settings
        app.buttons["URLBar.cancelButton"].tap()
        app.buttons["Settings"].tap()
        XCTAssertEqual(toggle.value as! String, "0")
    }
    
    func testEnableToggleHidesPrompt() {
        // Ensure search suggestions toggle is OFF initially
        waitforHittable(element: app.buttons["Settings"])
        app.buttons["Settings"].tap()
        let toggle = app.tables.switches["BlockerToggle.enableSearchSuggestions"]
        XCTAssertEqual(toggle.value as! String, "0")
        
        // Turn toggle ON
        toggle.tap()
        
        // Type in URL Bar, prompt should not show
        app.buttons["SettingsViewController.doneButton"].tap()
        app.textFields["Search or enter address"].tap()
        app.textFields["Search or enter address"].typeText("mozilla")
        waitforNoExistence(element: app.otherElements["SearchSuggestionsPromptView"])
    }
}
