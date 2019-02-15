//
//  NoInternetConnectionTest.swift
//  XCUITest
//
//  Created by Volodymyr Klymenko on 2019-02-01.
//  Copyright © 2019 Mozilla. All rights reserved.
//

import XCTest
import SystemConfiguration

public class ReachabilityTest {
	class func isConnectedToNetwork() -> Bool {
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)

		let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
				SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
			}
		}

		var flags = SCNetworkReachabilityFlags()
		if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
			return false
		}
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		return (isReachable && !needsConnection)
	}
}

class NoInternetConnectionTest: BaseTestCase {
	
	override func setUp() {
		super.setUp()
		dismissFirstRunUI()
	}

	override func tearDown() {
		app.terminate()
		super.tearDown()
	}

	func testConnectivity() {
		if !ReachabilityTest.isConnectedToNetwork() {
			loadWebPage("mozilla.com")
			let noInternetConnection = app.staticTexts["The Internet connection appears to be offline."]
			XCTAssertEqual("The Internet connection appears to be offline.", noInternetConnection.label)
		}
	}
}
