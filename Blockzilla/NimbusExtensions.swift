/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Nimbus

let NimbusServerURLKey = "NimbusServerURL"
let NimbusAppNameKey = "NimbusAppName"
let NimbusAppChannelKey = "NimbusAppChannel"

extension NimbusServerSettings {
    /// Create a `NimbusServerSettings` instance by looking up the server URL from the `Info.plist`.
    /// - Returns: <#description#>
    static func createFromInfoDictionary() -> NimbusServerSettings? {
        guard let serverURLString = Bundle.main.object(forInfoDictionaryKey: NimbusServerURLKey) as? String, let serverURL = URL(string: serverURLString) else {
            return nil
        }
        return NimbusServerSettings(url: serverURL)
    }
}

extension NimbusAppSettings {
    /// <#Description#>
    /// - Returns: <#description#>
    static func createFromInfoDictionary() -> NimbusAppSettings? {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: NimbusAppNameKey) as? String, let channel = Bundle.main.object(forInfoDictionaryKey: NimbusAppChannelKey) as? String else {
            return nil
        }
        return NimbusAppSettings(appName: appName, channel: channel)
    }
}
