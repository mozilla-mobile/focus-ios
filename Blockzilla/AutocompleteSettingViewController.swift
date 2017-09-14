
//
//  AutocompleteSettingViewController.swift
//  Blockzilla
//
//  Created by Joseph Gasiorek on 9/10/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

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
        return enabled ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return enabled ? domains.count + 1 : 0
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIConstants.colors.background
        
        title = UIConstants.strings.settingsAutocomplete
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIConstants.colors.background
        navigationBar.tintColor = UIConstants.colors.navigationButton
        navigationBar.titleTextAttributes = [.foregroundColor: UIConstants.colors.navigationTitle]

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIConstants.colors.background
        tableView.layoutMargins = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelText = section == 0 ? " " : UIConstants.strings.settingsCustomDomain
        
        let cell = UITableViewCell()
        cell.textLabel?.text = " "
        cell.backgroundColor = UIConstants.colors.background
        
        let label = UILabel()
        label.text = labelText
        label.textColor = UIConstants.colors.tableSectionHeader
        label.font = UIConstants.fonts.tableSectionHeader
        cell.contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.leading.trailing.equalTo(cell.textLabel!)
            make.centerY.equalTo(cell.textLabel!).offset(3)
        }
        
        // Hack to cover header separator line
        let footer = UIView()
        footer.backgroundColor = UIConstants.colors.background
        
        cell.addSubview(footer)
        
        footer.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(1)
            make.leading.trailing.equalToSuperview()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if (indexPath.section == 0) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "enableCell")
            cell.textLabel?.text = "Enable Domain Autocomplete"
            
            let toggle = UISwitch()
            toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
            toggle.isOn = enabled
            cell.accessoryView = PaddedSwitch(switchView: toggle)
            
        } else {
            if indexPath.row < domains.count {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "domainCell")
                cell.textLabel?.text = domains[indexPath.row]
            } else {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newDomainCell")
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Add Domain"
            }
        }
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIConstants.colors.cellSelected
        cell.selectedBackgroundView = backgroundColorView
        
        cell.backgroundColor = UIConstants.colors.background
        cell.textLabel?.textColor = UIConstants.colors.settingsTextLabel
        cell.layoutMargins = UIEdgeInsets.zero
        cell.detailTextLabel?.textColor = UIConstants.colors.settingsDetailLabel
        
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
        return nil
    }
    
    @objc private func toggleSwitched(_ sender: UISwitch) {
        enabled = sender.isOn
        Settings.set(enabled, forToggle: .enableDomainAutocomplete)
        tableView.reloadData()
    }
}

extension AutocompleteSettingViewController: AddCustomDomainDelegate {
    func addCustomDomainViewController(_ addCustomDomainViewController: AddCustomDomainViewController, domain: String) {
        domains.append(domain)
        tableView.reloadData()
        Settings.setCustomDomainSetting(domains: domains)
    }
}
