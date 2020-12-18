/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

class UserAgent {
    static let shared = UserAgent()

    private var userDefaults: UserDefaults
    private var isDesktopMode: Bool!

    var browserUserAgent: String?

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        setup()
    }

    func setup() {
        isDesktopMode = false
        if let cachedUserAgent = cachedUserAgent() {
            setUserAgent(userAgent: cachedUserAgent)
            return
        }

        let userAgent = UserAgent.mobileUserAgent()
        userDefaults.set(userAgent, forKey: "UserAgent")
        userDefaults.set(AppInfo.shortVersion, forKey: "LastFocusVersionNumber")
        userDefaults.set(AppInfo.buildNumber, forKey: "LastFocusBuildNumber")
        userDefaults.set(UIDevice.current.systemVersion, forKey: "LastDeviceSystemVersionNumber")

        setUserAgent(userAgent: userAgent)
    }

    private func cachedUserAgent() -> String? {
        let currentiOSVersion = UIDevice.current.systemVersion
        let lastiOSVersion = userDefaults.string(forKey: "LastDeviceSystemVersionNumber")
        let currentFocusVersion = AppInfo.shortVersion
        let lastFocusVersion = userDefaults.string(forKey: "LastFocusVersionNumber")
        let currentFocusBuild = AppInfo.buildNumber
        let lastFocusBuild = userDefaults.string(forKey: "LastFocusBuildNumber")

        if let focusUA = userDefaults.string(forKey: "UserAgent") {
            if lastiOSVersion == currentiOSVersion
                && lastFocusVersion == currentFocusVersion
                && lastFocusBuild == currentFocusBuild {
                return focusUA
            }
        }
        return nil
    }

    public static func getDesktopUserAgent() -> String {
        let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"
        return String(userAgent)
    }

    public func getUserAgent() -> String? {
        let userAgent = isDesktopMode ? UserAgent.getDesktopUserAgent() : userDefaults.string(forKey: "UserAgent")
        return userAgent
    }

    private func setUserAgent(userAgent: String) {
        userDefaults.register(defaults: ["UserAgent": userAgent])
    }

    public func changeUserAgent() {
        if isDesktopMode {
            setup()
        } else {
            setUserAgent(userAgent: UserAgent.getDesktopUserAgent())
            isDesktopMode = true
        }
    }

    public static func mobileUserAgent() -> String {
        return UserAgentBuilder.defaultMobileUserAgent().userAgent()
    }
}

struct UserAgentExtras {
    public static let uaBitSafari = "Safari/605.1.15"
    public static let uaBitMobile = "Mobile/15E148"
    public static let uaBitFx = "FxiOS/\(AppInfo.shortVersion)"
    public static let product = "Mozilla/5.0"
    public static let platform = "AppleWebKit/605.1.15"
    public static let platformDetails = "(KHTML, like Gecko)"
    // For iPad, we need to append this to the default UA for google.com to show correct page
    public static let uaBitGoogleIpad = "Version/13.0.3"
}

public struct UserAgentBuilder {
    // User agent components
    fileprivate var product = ""
    fileprivate var systemInfo = ""
    fileprivate var platform = ""
    fileprivate var platformDetails = ""
    fileprivate var extensions = ""

    init(product: String, systemInfo: String, platform: String, platformDetails: String, extensions: String) {
        self.product = product
        self.systemInfo = systemInfo
        self.platform = platform
        self.platformDetails = platformDetails
        self.extensions = extensions
    }

    public func userAgent() -> String {
        let userAgentItems = [product, systemInfo, platform, platformDetails, extensions]
        return removeEmptyComponentsAndJoin(uaItems: userAgentItems)
    }

    public func clone(product: String? = nil, systemInfo: String? = nil, platform: String? = nil, platformDetails: String? = nil, extensions: String? = nil) -> String {
        let userAgentItems = [product ?? self.product, systemInfo ?? self.systemInfo, platform ?? self.platform, platformDetails ?? self.platformDetails, extensions ?? self.extensions]
        return removeEmptyComponentsAndJoin(uaItems: userAgentItems)
    }

    /// Helper method to remove the empty components from user agent string that contain only whitespaces or are just empty
    private func removeEmptyComponentsAndJoin(uaItems: [String]) -> String {
        return uaItems.filter { !$0.isEmptyOrWhitespace() }.joined(separator: " ")
    }

    public static func defaultMobileUserAgent() -> UserAgentBuilder {
        return UserAgentBuilder(product: UserAgentExtras.product, systemInfo: "(\(UIDevice.current.model); CPU OS \(UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X)", platform: UserAgentExtras.platform, platformDetails: UserAgentExtras.platformDetails, extensions: "FxiOS/\(AppInfo.shortVersion)  \(UserAgentExtras.uaBitMobile) \(UserAgentExtras.uaBitSafari)")
    }

    public static func defaultDesktopUserAgent() -> UserAgentBuilder {
        return UserAgentBuilder(product: UserAgentExtras.product, systemInfo: "(Macintosh; Intel Mac OS X 10.15)", platform: UserAgentExtras.platform, platformDetails: UserAgentExtras.platformDetails, extensions: "FxiOS/\(AppInfo.shortVersion) \(UserAgentExtras.uaBitSafari)")
    }
}
