/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }

    var isUrl: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        guard let match = detector.firstMatch(in: self, range: NSRange(location: 0, length: self.count)), match.range.length == self.count else {
            return false
        }

        return true
    }

    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard count > limit else { return self }

        switch position {
        case .head:
            let truncated = self[index(endIndex, offsetBy: leader.count - limit)...]
            return leader + truncated
        case .middle:
            let headCharactersCount = (limit - leader.count) / 2
            let head = self[..<index(startIndex, offsetBy: headCharactersCount)]

            let tailCharactersCount = Int(ceil(Double(limit - leader.count) / 2.0))
            let tail = self[index(endIndex, offsetBy: -tailCharactersCount)...]

            return head + leader + tail
        case .tail:
            let truncated = self[..<index(startIndex, offsetBy: limit - leader.count)]
            return truncated + leader
        }
    }

    public func startsWith(other: String) -> Bool {
        // rangeOfString returns nil if other is empty, destroying the analogy with (ordered) sets.
        if other.isEmpty {
            return true
        }

        if let range = self.range(of: other, options: .anchored) {
            return range.lowerBound == self.startIndex
        }

        return false
    }
}
