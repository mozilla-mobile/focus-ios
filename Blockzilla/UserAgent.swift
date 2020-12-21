/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

struct UserAgentExtras {
    public static let uaBitSafari = "Safari/605.1.15"
    public static let uaBitMobile = "Mobile/15E148"
    public static let uaBitFx = "FxiOS/\(AppInfo.shortVersion)"
    public static let product = "Mozilla/5.0"
    public static let platform = "AppleWebKit/605.1.15"
    public static let platformDetails = "(KHTML, like Gecko)"
    public static let systemInfoDesktop = "(Macintosh; Intel Mac OS X 10_15_4)"
    public static let systemInfoMobile = "(\(UIDevice.current.model); CPU OS \(UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X)"
    // For iPad, we need to append this to the default UA for google.com to show correct page
    public static let uaBitGoogleIpad = "Version/13.1"
}

enum UserAgentMode {
    case desktop
    case mobile
}

class UserAgent {
    static let shared = UserAgent()

    private var userDefaults: UserDefaults
    private var defaultUserAgentDesktop = false
    private var forcedMode: UserAgentMode?

//    var browserUserAgent: String?

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        setup()
    }

    func setup() {
        if #available(iOS 15.0, *), UIDevice.current.userInterfaceIdiom == .pad {
            defaultUserAgentDesktop = true
        }
//        if let cachedUserAgent = cachedUserAgent() {
//            setUserAgent(userAgent: cachedUserAgent)
//            return
//        }
//
//        let userAgent = getUserAgent()
//        userDefaults.set(userAgent, forKey: "UserAgent")
//        userDefaults.set(AppInfo.shortVersion, forKey: "LastFocusVersionNumber")
//        userDefaults.set(AppInfo.buildNumber, forKey: "LastFocusBuildNumber")
//        userDefaults.set(UIDevice.current.systemVersion, forKey: "LastDeviceSystemVersionNumber")
//
//        setUserAgent(userAgent: userAgent)
    }

//    private func cachedUserAgent() -> String? {
//        let currentiOSVersion = UIDevice.current.systemVersion
//        let lastiOSVersion = userDefaults.string(forKey: "LastDeviceSystemVersionNumber")
//        let currentFocusVersion = AppInfo.shortVersion
//        let lastFocusVersion = userDefaults.string(forKey: "LastFocusVersionNumber")
//        let currentFocusBuild = AppInfo.buildNumber
//        let lastFocusBuild = userDefaults.string(forKey: "LastFocusBuildNumber")
//
//        if let focusUA = userDefaults.string(forKey: "UserAgent") {
//            if lastiOSVersion == currentiOSVersion
//                && lastFocusVersion == currentFocusVersion
//                && lastFocusBuild == currentFocusBuild {
//                return focusUA
//            }
//        }
//        return nil
//    }
//
    public static func getDesktopUserAgent() -> String {
        return "\(UserAgentExtras.product) \(UserAgentExtras.systemInfoDesktop) \(UserAgentExtras.platform) \(UserAgentExtras.platformDetails) \(UserAgentExtras.uaBitGoogleIpad) \(UserAgentExtras.uaBitSafari)"
    }

    public static func mobileUserAgent() -> String {
        return "\(UserAgentExtras.product) \(UserAgentExtras.systemInfoMobile) \(UserAgentExtras.platform) \(UserAgentExtras.platformDetails) FxiOS/\(AppInfo.shortVersion)  \(UserAgentExtras.uaBitMobile) \(UserAgentExtras.uaBitSafari)"
    }

    public func getUserAgent() -> String {
        let isDesktop: Bool = forcedMode == nil ? defaultUserAgentDesktop : forcedMode! == .desktop ? true : false
        let userAgent = isDesktop ? UserAgent.getDesktopUserAgent() : UserAgent.mobileUserAgent()
        return userAgent
    }

//    private func setUserAgent(userAgent: String) {
//        userDefaults.register(defaults: ["UserAgent": userAgent])
//    }

    public func changeUserAgent() {
        guard forcedMode == nil else {
            forcedMode = forcedMode == .desktop ? .mobile : .desktop
            return
        }
        forcedMode = defaultUserAgentDesktop ? .mobile : .desktop
    }
}
