/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

struct SectionItem {

    let id = UUID()

    let configureCell: (UITableView, IndexPath) -> UITableViewCell
    let action: (() -> Void)?

    init(configureCell: @escaping (UITableView, IndexPath) -> UITableViewCell, action: (() -> Void)? = nil) {
        self.configureCell = configureCell
        self.action = action
    }
}

extension SectionItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
