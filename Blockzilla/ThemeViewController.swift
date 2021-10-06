/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class ThemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        title = UIConstants.strings.theme
        navigationController?.navigationBar.tintColor = .accent
        view.backgroundColor = .systemBackground
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
