/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

enum SettingsToggle: String {
    case blockAds = "BlockAds"
    case blockAnalytics = "BlockAnalytics"
    case blockSocial = "BlockSocial"
    case blockOther = "BlockOther"
    case blockFonts = "BlockFonts"
    case safari = "Safari"
    case sendAnonymousUsageData = "SendAnonymousUsageData"
}

struct Settings {
    fileprivate static let prefs = UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!

    private static func defaultForToggle(_ toggle: SettingsToggle) -> Bool {
        switch toggle {
            case .blockAds: return true
            case .blockAnalytics: return true
            case .blockSocial: return true
            case .blockOther: return false
            case .blockFonts: return false
            case .safari: return true
            case .sendAnonymousUsageData: return AppInfo.isKlar ? false : true
        }
    }

    static func getToggle(_ toggle: SettingsToggle) -> Bool {
        return prefs.object(forKey: toggle.rawValue) as? Bool ?? defaultForToggle(toggle)
    }

    static func set(_ value: Bool, forToggle toggle: SettingsToggle) {
        prefs.set(value, forKey: toggle.rawValue)
        prefs.synchronize()
    }

    /// Returns true if the toggle's value is persisted, false otherwise.
    ///
    /// This is can usually be used to indicate, "Has the user ever toggled this pref?". One
    /// exception, for example, is that we persisted the default value for sendAnonymousUsageData
    /// in some cases (see AppDelegate.maybePersistTelemetrySetting).
    static func isToggleValuePersisted(_ toggle: SettingsToggle) -> Bool {
        // prefs.bool cannot be used for existence queries because it returns false if the value DNE.
        return prefs.object(forKey: toggle.rawValue) as? Bool != nil // TODO: need to be synchronized first?
    }
}
