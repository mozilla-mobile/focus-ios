/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
import Onboarding
import AppShortcuts

#if FOCUS
@testable import Firefox_Focus
#else
@testable import Firefox_Klar
#endif

class BrowserViewControllerTests: XCTestCase {
    private let mockUserDefaults = MockUserDefaults()
    
    private lazy var onboardingEventsHandler = OnboardingEventsHandlerV1(
        getShownTips: {
            return []
        }, setShownTips: { _ in
            
        }
    )
    
    private lazy var themeManager = ThemeManager()

    func testRequestReviewThreshold() {
        let bvc = BrowserViewController(
            shortcutManager: ShortcutsManager(),
            authenticationManager: AuthenticationManager(),
            onboardingEventsHandler: onboardingEventsHandler,
            themeManager: themeManager
        )
        mockUserDefaults.clear()

        // Ensure initial threshold is set
        mockUserDefaults.set(1, forKey: UIConstants.strings.userDefaultsLaunchCountKey)
        bvc.requestReviewIfNecessary()
        XCTAssert(mockUserDefaults.integer(forKey: UIConstants.strings.userDefaultsLaunchThresholdKey) == 14)
        XCTAssert(mockUserDefaults.object(forKey: UIConstants.strings.userDefaultsLastReviewRequestDate) == nil)

        // Trigger first actual review request
        mockUserDefaults.set(15, forKey: UIConstants.strings.userDefaultsLaunchCountKey)
        bvc.requestReviewIfNecessary()

        // Check second threshold and date are set
        XCTAssert(mockUserDefaults.integer(forKey: UIConstants.strings.userDefaultsLaunchThresholdKey) == 64)
        guard let prevDate = mockUserDefaults.object(forKey: UIConstants.strings.userDefaultsLastReviewRequestDate) as? Date else {
            XCTFail("userDefaultsLastReviewRequestDate not date")
            return
        }

        let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: prevDate, to: Date()).day ?? -1
        XCTAssert(daysSinceLastRequest == 0)

        // Trigger second review request with prevDate < 90 days (i.e. launch threshold should remain the same due to early return)
        mockUserDefaults.set(65, forKey: UIConstants.strings.userDefaultsLaunchCountKey)
        bvc.requestReviewIfNecessary()
        XCTAssert(mockUserDefaults.integer(forKey: UIConstants.strings.userDefaultsLaunchThresholdKey) == 64)

        // Trigger actual second review
        mockUserDefaults.set(nil, forKey: UIConstants.strings.userDefaultsLastReviewRequestDate)
        bvc.requestReviewIfNecessary()
        XCTAssert(mockUserDefaults.integer(forKey: UIConstants.strings.userDefaultsLaunchThresholdKey) == 114)
    }

    func testURLToProvideQuery() {
        let bvc = BrowserViewController(shortcutManager: ShortcutsManager(), authenticationManager: AuthenticationManager(), onboardingEventsHandler: onboardingEventsHandler, themeManager: themeManager)
        let urls = [URL(string: "https://www.google.com/search?q=test&rlz=1C5CHFA_enRO979RO979&oq=test&aqs=chrome..69i57j0i512l3j69i65j69i61l3.779j0j9&sourceid=chrome&ie=UTF-8"),
                   URL(string: "https://duckduckgo.com/?q=test&t=h_&ia=definition"),
                   URL(string: "https://www.amazon.com/s?k=test&crid=28Q4LOFU9OV84&sprefix=te%2Caps%2C180&ref=nb_sb_noss_2")
        ]
        XCTAssertEqual(bvc.urlBarDisplayTextForURL(urls[0]), ("test",true))
//        for url in urls {
//            XCTAssertEqual(bvc.urlBarDisplayTextForURL(url), ("test",true))
//        }
    }
}

private class MockUserDefaults: UserDefaults {
    func clear() {
        removeObject(forKey: BrowserViewController.userDefaultsTrackersBlockedKey)
        removeObject(forKey: UIConstants.strings.userDefaultsLastReviewRequestDate)
        removeObject(forKey: UIConstants.strings.userDefaultsLaunchCountKey)
        removeObject(forKey: UIConstants.strings.userDefaultsLaunchThresholdKey)
    }
}
