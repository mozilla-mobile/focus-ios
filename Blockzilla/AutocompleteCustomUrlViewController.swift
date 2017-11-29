/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class AutocompleteCustomUrlViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
