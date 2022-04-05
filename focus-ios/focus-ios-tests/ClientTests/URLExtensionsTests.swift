/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
import Foundation

class URLExtensionsTests: XCTestCase {
    
    // MARK: -- IPV4 Tests
    func testIPV4_Valid_Input_ShouldReturnTrue() {
        guard let url = URL.init(string: "www.google.com") else {
            XCTAssert(false);
            return;
        }
        XCTAssertTrue(url.isIPv4(host: "64.233.177.105"), "Test should not fail here for valid ipv4 hosts")
    }
    
    func testIPV4_Invalid_IP6Input_ShouldReturnFalse() {
        guard let url = URL.init(string: "www.google.com") else {
            XCTAssert(false);
            return;
        }
        XCTAssertFalse(url.isIPv4(host: "2607:f8b0:4002:c02::67"), "isIPv4 should always return false for IPV6 addresses")
    }
    
    func testIPV4_Invalid_EmptyInput_ShouldReturnFalse() {
        guard let url = URL.init(string: "www.google.com") else {
            XCTAssert(false);
            return;
        }
        XCTAssertFalse(url.isIPv4(host: ""), "isIPv4 should always return false for empty hosts.")
    }
    
    // MARK: -- IPV6 Tests
    func testIPV6_Valid_Input_ShouldReturnTrue() {
        guard let url = URL.init(string: "www.google.com") else {
            XCTAssert(false);
            return;
        }
        XCTAssertTrue(url.isIPv6(host: "2607:f8b0:4002:c02::67"), "Test should not fail here for valid ipv6 hosts")
    }
    
    func testIPV4_Invalid_IP4Input_ShouldReturnFalse() {
        guard let url = URL.init(string: "www.google.com") else {
            XCTAssert(false);
            return;
        }
        XCTAssertFalse(url.isIPv6(host: "64.233.177.105"), "isIPv6 should always return false for IPV4 addresses")
    }
    
    func testIPV6_Invalid_EmptyInput_ShouldReturnFalse() {
        guard let url = URL.init(string: "www.google.com") else {
            XCTAssert(false);
            return;
        }
        XCTAssertFalse(url.isIPv6(host: ""), "isIPv6 should always return false for empty hosts.")
    }
    
    
}
