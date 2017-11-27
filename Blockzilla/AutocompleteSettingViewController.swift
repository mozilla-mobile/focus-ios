
//
//  AutocompleteSettingViewController.swift
//  Blockzilla
//
//  Created by Joseph Gasiorek on 9/10/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import Telemetry

protocol AutocompleteSettingDelegate {
    func autocompleteSettingViewController(_ autocompleteSettingViewController: AutocompleteSettingViewController, enabled: Bool, didUpdateDomains domains: [String])
}

class AutocompleteSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate var domains: [String]
    private let delegate: AutocompleteSettingDelegate
    fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
    private var enabled: Bool
    
    init(enabled: Bool, domains: [String], delegate: AutocompleteSettingDelegate) {
        self.enabled = enabled
        self.domains = domains
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            toggle.isOn = enabled
            cell.accessoryView = PaddedSwitch(switchView: toggle)
            
        } else {
            if indexPath.row == 0 {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "enableCell")
                cell.textLabel?.text = UIConstants.strings.autocompleteLabel

                let toggle = UISwitch()
                toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
                toggle.accessibilityIdentifier = "toggleAutocompleteSwitch"
                toggle.isOn = enabled
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
        
        if indexPath.section == 1 && indexPath.row == domains.count {
            // Add Custom Domain Tapped
            let viewController = AddCustomDomainViewController(delegate: self)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || !tableView.isEditing {
            return false
        }
        
        return indexPath.row < domains.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            domains.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @objc private func toggleSwitched(_ sender: UISwitch) {
        enabled = sender.isOn
        Settings.set(enabled, forToggle: .enableDomainAutocomplete)
        tableView.reloadData()
    }

}

extension AutocompleteSettingViewController: AddCustomDomainDelegate {
    func addCustomDomainViewController(_ addCustomDomainViewController: AddCustomDomainViewController, domain: String) {
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.customDomainAdded, object: TelemetryEventObject.setting)
        domains.append(domain)
        tableView.reloadData()
        Settings.setCustomDomainSetting(domains: domains)
    }
}
