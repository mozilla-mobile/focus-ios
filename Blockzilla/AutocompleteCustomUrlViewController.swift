/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Telemetry

class AutocompleteCustomUrlViewController: UIViewController {
    private let emptyStateView = UIView()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var addDomainCell: UITableViewCell?

    private let customAutocompleteSource: CustomAutocompleteSource
    private var domains: [String] { return customAutocompleteSource.getSuggestions() }

    init(customAutocompleteSource: CustomAutocompleteSource) {
        self.customAutocompleteSource = customAutocompleteSource
        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.edit, style: .plain, target: self, action: #selector(AutocompleteCustomUrlViewController.toggleEditing))

        view.addSubview(tableView)

        let label = UILabel()
        label.text = UIConstants.strings.autocompleteEmptyState
        label.font = UIConstants.fonts.settingsDescriptionText
        label.textColor = UIConstants.colors.settingsTextLabel
        label.textAlignment = .center
        emptyStateView.addSubview(label)
        tableView.backgroundView = emptyStateView
        tableView.backgroundView?.isHidden = true

        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        updateEmptyStateView()
    }

    fileprivate func updateEmptyStateView() {
        tableView.backgroundView?.animateHidden(!(tableView.isEditing && domains.isEmpty), duration: 0.2)
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

            let backgroundColorView = UIView()
            backgroundColorView.backgroundColor = UIConstants.colors.cellSelected

            cell.selectedBackgroundView = backgroundColorView
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == domains.count {
            let viewController = AddCustomDomainViewController(delegate: self)

            if UIDevice.current.userInterfaceIdiom == .pad {
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.modalPresentationStyle = .formSheet
                let navigationBar = navigationController.navigationBar
                navigationBar.isTranslucent = false
                navigationBar.barTintColor = UIConstants.colors.background
                navigationBar.tintColor = UIConstants.colors.navigationButton
                navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIConstants.colors.navigationTitle]

                present(navigationController, animated: true, completion: nil)

            } else {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension AutocompleteCustomUrlViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension AutocompleteCustomUrlViewController: AddCustomDomainDelegate {
    func addCustomDomainViewController(_ addCustomDomainViewController: AddCustomDomainViewController, domain: String) {
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.customDomainAdded, object: TelemetryEventObject.setting)
        _ = customAutocompleteSource.add(suggestion: domain)
        tableView.reloadData()
    }
}
