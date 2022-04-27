/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

struct Shortcut: Equatable, Codable, Hashable {
    var url: URL
    var name: String
    
    init(url: URL, name: String = "") {
        self.url = url
        self.name = name.isEmpty ? Shortcut.defaultName(for: url) : name
    }
}

extension Shortcut {
    private static func defaultName(for url: URL) -> String {
        if let host = url.host {
            var shortUrl = host.replacingOccurrences(of: "www.", with: "")
            if shortUrl.hasPrefix("mobile.") {
                shortUrl = shortUrl.replacingOccurrences(of: "mobile.", with: "")
            }
            if shortUrl.hasPrefix("m.") {
                shortUrl = shortUrl.replacingOccurrences(of: "m.", with: "")
            }
            if let domain = shortUrl.components(separatedBy: ".").first?.capitalized {
                return domain
            }
        }
        return ""
    }
}
