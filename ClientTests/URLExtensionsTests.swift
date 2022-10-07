// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
import Network

final class URLExtensionsTests: XCTestCase {
    func testIsIPv4() throws {
        let url = try XCTUnwrap(URL(string: "192.168.1.1"))
        XCTAssertTrue(url.isIPv4)
    }

    func testIsNotIPv4() throws {
        let url = try XCTUnwrap(URL(string: "https://www.mozilla.org"))
        XCTAssertFalse(url.isIPv4)
    }

    func testIsIPv6() throws {
        let url = try XCTUnwrap(URL(string: "2345:0425:2CA1:0000:0000:0567:5673:23b5"))
        XCTAssertTrue(url.isIPv6)
    }

    func testIsNotIPv6() throws {
        let url = try XCTUnwrap(URL(string: "https://www.mozilla.org"))
        XCTAssertFalse(url.isIPv6)
    }
}
