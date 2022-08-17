/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
@testable import Firefox_Focus
import WebKit

class TrackingAdsTests: XCTestCase {
    
    let tpm = TrackingProtectionManager(isTrackingEnabled: {
        Settings.getToggle(.trackingProtection)
    })
    lazy var wvc = WebViewController(trackingProtectionManager: tpm)
    
    override func setUpWithError() throws {
        
    }
    
    func testGetProviderNil() throws {
        let mockData: [String: String] = ["url": "saasj"]
        let result = wvc.getProviderForMessage(message: mockData)
        XCTAssertEqual(result?.name, nil)
    }
    
    func testGetProviderGoogle() throws {
        let mockData: [String: String] = ["url": "https://www.google.com/search?q=iphone&rlz=1C5CHFA_enRO979RO979&oq=iphone&aqs=chrome..69i57j0i512l9.2034j0j7&sourceid=chrome&ie=UTF-8"]
        let result = wvc.getProviderForMessage(message: mockData)
        XCTAssertEqual(result?.name, BasicSearchProvider.google.rawValue)
    }
    
    func testGetProviderDuckDuckGo() throws {
        let mockData: [String: String] = ["url": "https://duckduckgo.com/?q=iphone&t=ha&va=j&ia=web"]
        let result = wvc.getProviderForMessage(message: mockData)
        XCTAssertEqual(result?.name, BasicSearchProvider.duckduckgo.rawValue)
    }
    
    func testGetProviderBing() throws {
        let mockData: [String: String] = ["url": "https://www.bing.com/search?q=iphone&form=QBLH&sp=-1&pq=ipho&sc=10-4&qs=n&sk=&cvid=3AE803700EA346D0A67F5E6FE8E661A9&ghsh=0&ghacc=0&ghpl="]
        let result = wvc.getProviderForMessage(message: mockData)
        XCTAssertEqual(result?.name, BasicSearchProvider.bing.rawValue)
    }
    
    func testGetProviderYahoo() throws {
        let mockData: [String: String] = ["url": "https://ro.search.yahoo.com/search?p=iphone&fr=yfp-t&fr2=p%3Afp%2Cm%3Asb&ei=UTF-8&fp=1"]
        let result = wvc.getProviderForMessage(message: mockData)
        XCTAssertEqual(result?.name, BasicSearchProvider.yahoo.rawValue)
    }

}
