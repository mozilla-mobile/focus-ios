// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

#if FOCUS
@testable import Firefox_Focus
#else
@testable import Firefox_Klar
#endif

class NavigationPathTests: XCTestCase {
    
    private var appScheme: String {
        AppInfo.isKlar ? "firefox-klar" : "firefox-focus"
    }
    
    private var appURL: String!
    private var navigation: NavigationPath!
    private let url = "https://www.apple.com/"
    private let badURL = "boomer"
    
    override func setUp() {
        super.setUp()
        appURL = ""
        navigation = nil
    }
    
    func testOpenURLschemeGoodURL() {
        appURL = "\(appScheme)://open-url?url=\(url)"
        navigation = NavigationPath(url: URL(string: appURL)!)!
        XCTAssertEqual(navigation,
                       NavigationPath.url(URL(string: url)!))
    }
    
    func testOpenURLschemeBadURL() {
        appURL = "\(appScheme)://open-url?url=\(badURL)"
        navigation = NavigationPath(url: URL(string: appURL)!)
        XCTAssertEqual(navigation,
                       NavigationPath.url(URL(string: badURL)!))
    }
    
    func testOpenTextSchemeGoodURL() {
        appURL = "\(appScheme)://open-text?text=\(url)"
        navigation = NavigationPath(url: URL(string: appURL)!)!
        XCTAssertEqual(navigation,
                       NavigationPath.text(url))
    }
    
    func testOpenTextSchemeBadURL() {
        appURL = "\(appScheme)://open-text?text=\(badURL)"
        navigation = NavigationPath(url: URL(string: appURL)!)!
        XCTAssertEqual(navigation,
                       NavigationPath.text(badURL))
    }
    
    func testCaseInsensitivity() {
        XCTAssertEqual(NavigationPath(url: URL(string: "HtTpS://www.apple.com")!),
                       NavigationPath.url(URL(string: "https://www.apple.com")!))
        
        XCTAssertEqual(NavigationPath(url: URL(string: "\(appScheme.uppercased())://open-url?url=\(url)")!),
                       NavigationPath.url(URL(string: url)!))
    }
}
