/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Telemetry

class AutocompleteSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIConstants.colors.background
        
        title = UIConstants.strings.settingsAutocompleteSection

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIConstants.colors.background
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorColor = UIConstants.colors.settingsSeparator
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelText: String

        switch section {
        case 0: labelText = UIConstants.strings.autocompleteDefaultSectionTitle
        case 1: labelText = UIConstants.strings.autocompleteCustomSectionTitle
        default: fatalError("No title for section: \(section)")
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = labelText
        cell.textLabel?.textColor = UIConstants.colors.tableSectionHeader
        cell.textLabel?.font = UIConstants.fonts.tableSectionHeader
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if (indexPath.section == 0) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "enableCell")
            cell.textLabel?.text = UIConstants.strings.autocompleteLabel
            
            let toggle = UISwitch()
            toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
            toggle.accessibilityIdentifier = "toggleAutocompleteSwitch"
            toggle.isOn = Settings.getToggle(.enableDomainAutocomplete)
            cell.accessoryView = PaddedSwitch(switchView: toggle)
            
        } else {
            if indexPath.row == 0 {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "enableCell")
                cell.textLabel?.text = UIConstants.strings.autocompleteLabel

                let toggle = UISwitch()
                toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
                toggle.accessibilityIdentifier = "toggleCustomAutocompleteSwitch"
                toggle.isOn = Settings.getToggle(.enableCustomDomainAutocomplete)
                cell.accessoryView = PaddedSwitch(switchView: toggle)
            } else {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newDomainCell")
                cell.accessoryType = .disclosureIndicator
                cell.accessibilityIdentifier = "customURLS"
                cell.textLabel?.text = UIConstants.strings.autocompleteCustomSectionLabel
            }
        }
        
        cell.backgroundColor = UIConstants.colors.background
        cell.textLabel?.textColor = UIConstants.colors.settingsTextLabel
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 1 {
            let viewController = AutocompleteCustomUrlViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let learnMore = NSAttributedString(string: UIConstants.strings.learnMore, attributes: [NSAttributedStringKey.foregroundColor : UIConstants.colors.toggleOn])
            let subtitle = NSMutableAttributedString(string: String(format: UIConstants.strings.autocompleteDefaultDescription, AppInfo.productName), attributes: [NSAttributedStringKey.foregroundColor : UIConstants.colors.settingsDetailLabel])
            let space = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.foregroundColor : UIConstants.colors.toggleOn])
            subtitle.append(space)
            subtitle.append(learnMore)
            cell.detailTextLabel?.attributedText = subtitle
            cell.detailTextLabel?.numberOfLines = 0
            cell.accessibilityIdentifier = "SettingsViewController.trackingProtectionLearnMoreCell"
            cell.selectionStyle = .none
            cell.backgroundColor = UIConstants.colors.background
            cell.layoutMargins = UIEdgeInsets.zero

            return cell
        case 1:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let learnMore = NSAttributedString(string: UIConstants.strings.learnMore, attributes: [NSAttributedStringKey.foregroundColor : UIConstants.colors.toggleOn])
            let subtitle = NSMutableAttributedString(string: String(format: UIConstants.strings.autocompleteCustomDescription, AppInfo.productName), attributes: [NSAttributedStringKey.foregroundColor : UIConstants.colors.settingsDetailLabel])
            let space = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.foregroundColor : UIConstants.colors.toggleOn])
            subtitle.append(space)
            subtitle.append(learnMore)
            cell.detailTextLabel?.attributedText = subtitle
            cell.detailTextLabel?.numberOfLines = 0
            cell.accessibilityIdentifier = "SettingsViewController.learnMoreCell"
            cell.selectionStyle = .none
            cell.backgroundColor = UIConstants.colors.background
            cell.layoutMargins = UIEdgeInsets.zero

            return cell
        default: return nil
        }
    }

    @objc private func toggleSwitched(_ sender: UISwitch) {
        let enabled = sender.isOn
        Settings.set(enabled, forToggle: .enableDomainAutocomplete)
    }

}



