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

    func testEmptyStringSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForQuery(EMPTY_STRING_SEARCH)
        XCTAssertNil(searchURL)
    }
    
    func testWhiteSpaceSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForQuery(WHITE_SPACE_CHAR_SEARCH)
        XCTAssertNil(searchURL)
    }
    
    func testNewLineSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForQuery(NEW_LINE_CHAR_SEARCH)
        XCTAssertNil(searchURL)
    }
    
    func testSpecialCharacterSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForQuery(SPECIAL_CHAR_SEARCH)
        XCTAssertNotNil(searchURL)
    }
    
    func testNormalSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let searchURL = engine.urlForQuery(NORMAL_SEARCH)
        XCTAssertNotNil(searchURL)
    }
    
    func testBeginWithWhiteSpaceSearchSuggestions() {
        let manager = SearchEngineManager(prefs: UserDefaults.standard)
        let engine = manager.activeEngine
        
        let normalSearchURL = engine.urlForQuery(NORMAL_SEARCH)
        let testSearchURL = engine.urlForQuery(BEGIN_WITH_WHITE_SPACE_SEARCH)
        XCTAssertEqual(normalSearchURL, testSearchURL)
    }
}
