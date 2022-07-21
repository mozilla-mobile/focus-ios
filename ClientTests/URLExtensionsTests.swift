/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

#if FOCUS
@testable import Firefox_Focus
#else
@testable import Firefox_Klar
#endif

final class URLExtensionsTests: XCTestCase {

    private let validIPV6 = ["https://[684D:1111:222:3333:4444:5555:6:77]",
                             "https://[2001:0db8:0001:0000:0000:0ab9:C0A8:0102]",
                             "https://[2001:db8:1::ab9:C0A8:102]",
                             "https://[::2001:db8:1:ab9]",
                             "https://[2001:db8:1:ab9:C0A8::]",
                             "https://[::]"]

    private let invalidIPV6 = ["https://127.0.0.1",
                               "https://[127]",
                               "https://[:]",
                               "https://[2001:db8::1::102]",
                               "https://[2001:db8:1:1:1:11:c099:202:bb:1]",
                               "https://[:2001:db8:1:ab9:C0A8:102]",
                               "https://[2001:db8:1:C0A8:102]"]

    private let validIPV4 = ["https://127.0.0.1",
                             "https://127.0.0.1?mozilla=true"]

    private let invalidIPV4 = ["https://1271",
                               "https://www.mozilla.com",
                               "https://mozilla.com",
                               "https://127.0.1",
                               "https://127.000000.1",
                               "https://127.0.0.1.2.3.4.5"]

    func testValidIPv6Addresses() throws {
        validIPV6.forEach {
            let url = URL(string: $0)
            XCTAssertNotNil(url?.host, $0)
            XCTAssertTrue(url!.isIPv6, $0)
        }
    }

    func testInvalidIPv6Addresses() throws {
        invalidIPV6.forEach {
            let url = URL(string: $0)
            XCTAssertNotNil(url?.host, $0)
            XCTAssertFalse(url!.isIPv6, $0)
        }
    }

    func testValidIPv4Addresses() throws {
        validIPV4.forEach {
            let url = URL(string: $0)
            XCTAssertNotNil(url?.host, $0)
            XCTAssertTrue(url!.isIPv4, $0)
        }
    }

    func testInvalidIPv4Addresses() throws {
        invalidIPV4.forEach {
            let url = URL(string: $0)
            XCTAssertNotNil(url?.host, $0)
            XCTAssertFalse(url!.isIPv4, $0)
        }
    }

}
