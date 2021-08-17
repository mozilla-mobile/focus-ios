/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

/// Utility functions related to SUMO.
public struct SupportUtils {
    /// Construct an URL pointing to a specific topic on SUMO. The topic comes from the Topics enum.
    ///
    /// The resulting URL will include the app version, operating system and locale code. For example, a topic
    /// "cheese" will be turned into a link that looks like https://support.mozilla.org/1/mobile/2.0/iOS/en-US/cheese
    ///
    /// If for some reason the URL could not be created, a default URL to support.mozilla.org is returned. This is
    /// a very rare case that should not happen except in the rare case where the URL may be dynamically formatted.
    
}

public enum SupportTopic {
    case whatsNew
    case searchSuggestions
    case usageData
    case autofillDomain
    case trackingProtection
    case addSearchEngine
    
    func topicString() -> String {
        switch self {
        case .whatsNew:
            return String(format: "whats-new-%@-ios-%@", AppInfo.config.productName.lowercased(), AppInfo.majorVersion)
        case .searchSuggestions:
            return "search-suggestions-focus-ios"
        case .usageData:
            return "usage-data"
        case .autofillDomain:
            return "autofill-domain-ios"
        case .trackingProtection:
            return "tracking-protection-focus-ios"
        case .addSearchEngine:
            return "add-search-engine-ios"
        }
    }
}

extension URL {
    init(forSupportTopic topic: SupportTopic) {
        if let escapedTopic = topic.topicString().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed), let languageIdentifier = Locale.preferredLanguages.first {
            let url = "https://support.mozilla.org/1/mobile/\(AppInfo.shortVersion)/iOS/\(languageIdentifier)/\(escapedTopic)"
            print("DEHJDHEKJHKJDEHKJDHEKJHDEK")
            print(url)
            self.init(string: url)!
        }
        self.init(string: "https://support.mozilla.org")!
    }
}
