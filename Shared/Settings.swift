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
    // No longer used, but will be set to true in existing users' settings.
    static let keyIntroDone = "IntroDone"

    fileprivate static let prefs = UserDefaults(suiteName: AppInfo.SharedContainerIdentifier)!

    private static func defaultForToggle(_ toggle: SettingsToggle) -> Bool {
        switch toggle {
            case .blockAds: return true
            case .blockAnalytics: return true
            case .blockSocial: return true
            case .blockOther: return false
            case .blockFonts: return false
            case .safari: return true
            case .sendAnonymousUsageData: return true
        }
    }

    static func getToggle(_ toggle: SettingsToggle) -> Bool {
        return prefs.object(forKey: toggle.rawValue) as? Bool ?? defaultForToggle(toggle)
    }

    static func set(_ value: Bool, forToggle toggle: SettingsToggle) {
        prefs.set(value, forKey: toggle.rawValue)
        prefs.synchronize()
    }
}
