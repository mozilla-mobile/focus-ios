/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public enum SupportTopic: CaseIterable {
    case whatsNew
    case searchSuggestions
    case usageData
    case studies
    case autofillDomain
    case trackingProtection
    case addSearchEngine

    public var slug: String {
        switch self {
        case .whatsNew:
            return "whats-new-\(AppInfo.config.productName.lowercased())-ios-\(AppInfo.majorVersion)"
        case .searchSuggestions:
            return "search-suggestions-focus-ios"
        case .usageData:
            return "usage-data"
        case .studies:
            return "studies-focus-ios"
        case .autofillDomain:
            return "autofill-domain-ios"
        case .trackingProtection:
            return "tracking-protection-focus-ios"
        case .addSearchEngine:
            return "add-search-engine-ios"
        }
    }
    
    static let fallbackURL = "https://support.mozilla.org"
}
