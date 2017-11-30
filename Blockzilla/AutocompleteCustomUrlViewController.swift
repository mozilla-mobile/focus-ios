/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class AutocompleteCustomUrlViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var addDomainCell: UITableViewCell?

    var domains: [String] = ["http://hackerne.ws"]

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.edit, style: .plain, target: self, action: #selector(AutocompleteCustomUrlViewController.toggleEditing))

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        view.backgroundColor = UIConstants.colors.background

        title = UIConstants.strings.autocompleteCustomSectionLabel

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIConstants.colors.background
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorColor = UIConstants.colors.settingsSeparator
    }

    @objc private func toggleEditing() {
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? UIConstants.strings.edit : UIConstants.strings.done

        tableView.setEditing(!tableView.isEditing, animated: true)
        addDomainCell?.animateHidden(tableView.isEditing, duration: 0.2)
    }
}

extension AutocompleteCustomUrlViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return domains.count + 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = UITableViewCell()
        cell.backgroundColor = UIConstants.colors.background

        // Hack to cover header separator line
        let footer = UIView()
        footer.backgroundColor = UIConstants.colors.background

        cell.addSubview(footer)
        cell.sendSubview(toBack: footer)

        footer.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(1)
            make.leading.trailing.equalToSuperview()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if (indexPath.row == domains.count) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "addCustomDomainCell")
            cell.textLabel?.text = UIConstants.strings.autocompleteAddCustomUrlWithPlus
            cell.accessoryType = .disclosureIndicator
            addDomainCell = cell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "domainCell")
            cell.selectionStyle = .none
            cell.textLabel?.text = domains[indexPath.row]
        }

        cell.backgroundColor = UIConstants.colors.background
        cell.textLabel?.textColor = UIConstants.colors.settingsTextLabel
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row !=  domains.count
    }
}

extension AutocompleteCustomUrlViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
