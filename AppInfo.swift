/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public class AppInfo {
    /// Return the shared container identifier (also known as the app group) to be used with for example background
    /// http requests. It is the base bundle identifier with a "group." prefix.
    public static func sharedContainerIdentifier() -> String? {
        if let baseBundleIdentifier = AppInfo.baseBundleIdentifier() {
            return "group." + baseBundleIdentifier
        }
        return nil
    }

    /// Return the base bundle identifier.
    ///
    /// This function is smart enough to find out if it is being called from an extension or the main application. In
    /// case of the former, it will chop off the extension identifier from the bundle since that is a suffix not part
    /// of the *base* bundle identifier.
    public static func baseBundleIdentifier() -> String? {
        let bundle = NSBundle.mainBundle()
        if let packageType = bundle.objectForInfoDictionaryKey("CFBundlePackageType") as? NSString {
            if let baseBundleIdentifier = bundle.bundleIdentifier {
                if packageType == "XPC!" {
                    let components = baseBundleIdentifier.componentsSeparatedByString(".")
                    return components[0..<components.count-1].joinWithSeparator(".")
                }
                return baseBundleIdentifier
            }
        }
        return nil
    }

    /// Return the bundle identifier of the content blocker extension. We can't simply look it up from the
    /// NSBundle because this code can be called from both the main app and the extension.
    public static func contentBlockerBundleIdentifier() -> String? {
        guard let baseBundleIdentifier = baseBundleIdentifier() else {
            return nil
        }
        return baseBundleIdentifier + ".ContentBlocker"
    }
}