/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

#if FOCUS
@testable import Firefox_Focus
#else
@testable import Firefox_Klar
#endif

class SearchEngineTests: XCTestCase {
    private let EMPTY_STRING_SEARCH = ""
    private let WHITE_SPACE_CHAR_SEARCH = " "
    private let SPECIAL_CHAR_SEARCH = "\""
    private let NEW_LINE_CHAR_SEARCH = "\n"
    private let NORMAL_SEARCH = "example"
    private let BEGIN_WITH_WHITE_SPACE_SEARCH = " example"

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEmptyStringQuery() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let queryURL = engine.urlForQuery(EMPTY_STRING_SEARCH)
        XCTAssertNil(queryURL)
    }
    
    func testEmptyStringSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForSuggestions(EMPTY_STRING_SEARCH)
        XCTAssertNil(searchURL)
    }
    
    func testWhiteSpaceQuery() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let queryURL = engine.urlForQuery(WHITE_SPACE_CHAR_SEARCH)
        XCTAssertNil(queryURL)
    }
    
    func testWhiteSpaceSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForSuggestions(WHITE_SPACE_CHAR_SEARCH)
        XCTAssertNil(searchURL)
    }
    
    func testNewLineQuery() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let queryURL = engine.urlForQuery(NEW_LINE_CHAR_SEARCH)
        XCTAssertNil(queryURL)
    }
    
    func testNewLineSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForSuggestions(NEW_LINE_CHAR_SEARCH)
        XCTAssertNil(searchURL)
    }
    
    func testSpecialCharacterQuery() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let queryURL = engine.urlForQuery(SPECIAL_CHAR_SEARCH)
        XCTAssertNotNil(queryURL)
    }
    
    func testSpecialCharacterSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForSuggestions(SPECIAL_CHAR_SEARCH)
        XCTAssertNotNil(searchURL)
    }
    
    func testNormalQuery() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let queryURL = engine.urlForQuery(NORMAL_SEARCH)
        XCTAssertNotNil(queryURL)
    }
    
    func testNormalSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForSuggestions(NORMAL_SEARCH)
        XCTAssertNotNil(searchURL)
    }
    
    func testBeginWithWhiteSpaceQuery() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let normalQueryURL = engine.urlForQuery(NORMAL_SEARCH)
        let testQueryURL = engine.urlForQuery(BEGIN_WITH_WHITE_SPACE_SEARCH)
        XCTAssertEqual(normalQueryURL, testQueryURL)
    }
    
    func testBeginWithWhiteSpaceSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let normalSearchURL = engine.urlForSuggestions(NORMAL_SEARCH)
        let testSearchURL = engine.urlForSuggestions(BEGIN_WITH_WHITE_SPACE_SEARCH)
        XCTAssertEqual(normalSearchURL, testSearchURL)
    }
}
