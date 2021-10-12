/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class ThemeTableViewAccessoryCell: UITableViewCell {
    var labelText: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIConstants.colors.cellSelected
        selectedBackgroundView = backgroundColorView
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byWordWrapping
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.lineBreakMode = .byWordWrapping
        selectionStyle = .none
        tintColor = .secondaryText.withAlphaComponent(0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ThemeTableViewToggleCell: UITableViewCell {
    var toggle = UISwitch()
    weak var delegate: SystemThemeDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIConstants.colors.cellSelected
        selectedBackgroundView = backgroundColorView
        textLabel?.numberOfLines = 0
        textLabel?.text = "Use system light/dark theme"
        backgroundColor = UIConstants.colors.cellBackground
        textLabel?.textColor = .primaryText
        layoutMargins = UIEdgeInsets.zero
        toggle.onTintColor = .accent
        toggle.tintColor = .darkGray
        toggle.addTarget(self, action: #selector(toggleSwitched(_:)), for: .valueChanged)
        toggle.isOn = UserDefaults.standard.theme.userInterfaceStyle == .unspecified
        accessoryView = PaddedSwitch(switchView: toggle)
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func toggleSwitched(_ sender: UISwitch) {
    delegate?.didEnableSystemTheme(sender.isOn)
    }
}

protocol SystemThemeDelegate: AnyObject {
    func didEnableSystemTheme(_ isEnabled: Bool)
}

class ThemeViewController: UIViewController, SystemThemeDelegate {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var currentTheme: UIUserInterfaceStyle {
        return UserDefaults.standard.theme.userInterfaceStyle
    }
    
    override func viewDidLoad() {
        title = UIConstants.strings.theme
        navigationController?.navigationBar.tintColor = .accent
        view.backgroundColor = .systemBackground
        
        tableView.backgroundColor = .systemBackground
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.view)
            make.leading.trailing.equalTo(self.view).inset(UIConstants.layout.settingsItemInset)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func configureStyle(for theme: Theme) {
      view.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
    }
    
    func didEnableSystemTheme(_ isEnabled: Bool) {
        configureStyle(for: isEnabled ? .device : .light)
        UserDefaults.standard.theme = isEnabled ? .device : .light
        tableView.reloadData()
    }
}

extension ThemeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentTheme == .unspecified ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = ThemeTableViewToggleCell(style: .subtitle, reuseIdentifier: "toggleCell")
            cell.accessibilityIdentifier = "themeViewController.themetoogleCell"
            (cell as? ThemeTableViewToggleCell)?.delegate =  self
            
        default:
            let themeCell = ThemeTableViewAccessoryCell(style: .value1, reuseIdentifier: "themeCell")
            themeCell.labelText = indexPath.row == 0 ? UIConstants.strings.light : UIConstants.strings.dark
            themeCell.accessibilityIdentifier = "themeViewController.themeCell"
            let checkmarkImageView = UIImageView(image: UIImage(named: "custom_checkmark"))
            if currentTheme == .light {
                themeCell.accessoryView = indexPath.row == 0 ? checkmarkImageView : .none
            } else if currentTheme == .dark {
                themeCell.accessoryView = indexPath.row == 1 ? checkmarkImageView : .none
            }
            cell = themeCell
        }
        
        cell.backgroundColor = .secondarySystemBackground
        cell.textLabel?.textColor = .primaryText
        cell.layoutMargins = UIEdgeInsets.zero
        cell.detailTextLabel?.textColor = .secondaryText
        cell.textLabel?.setupShrinkage()
        cell.detailTextLabel?.setupShrinkage()
        cell.addSeparator(tableView: tableView, indexPath: indexPath, leadingOffset: UIConstants.layout.cellSeparatorLeadingOffset)
        
        return cell
    }
}

extension ThemeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.roundedCorners(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let groupingOffset = UIConstants.layout.settingsDefaultTitleOffset
        
        let cell = UITableViewCell()
        cell.textLabel?.text = " "
        cell.backgroundColor = .systemBackground
        
        let label = SmartLabel()
        switch section {
        case 0:
            label.text = UIConstants.strings.systemTheme.uppercased()
        default:
            label.text = UIConstants.strings.themePicker.uppercased()
        }
        label.textColor = .secondaryText
        label.font = UIConstants.fonts.tableSectionHeader
        cell.contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.leading.trailing.equalTo(cell.textLabel!)
            make.centerY.equalTo(cell.textLabel!).offset(groupingOffset)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                configureStyle(for: .light)
                UserDefaults.standard.theme = .light
            } else {
                configureStyle(for: .dark)
                UserDefaults.standard.theme = .dark
            }
        default:
            break
        }
        
        tableView.reloadData()
    }
}
