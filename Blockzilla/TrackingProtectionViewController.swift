/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import UIKit
import Telemetry

class TrackingProtectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate let tableView = UITableView(frame: .zero, style: .plain)
    
    private let toggles = [
        BlockerToggle(label: UIConstants.strings.labelBlockAds, setting: SettingsToggle.blockAds, subtitle: UIConstants.strings.labelBlockAdsDescription),
        BlockerToggle(label: UIConstants.strings.labelBlockAnalytics, setting: SettingsToggle.blockAnalytics, subtitle: UIConstants.strings.labelBlockAnalyticsDescription),
        BlockerToggle(label: UIConstants.strings.labelBlockSocial, setting: SettingsToggle.blockSocial, subtitle: UIConstants.strings.labelBlockSocialDescription),
        BlockerToggle(label: UIConstants.strings.labelBlockOther, setting: SettingsToggle.blockOther, subtitle: UIConstants.strings.labelBlockOtherDescription)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIConstants.colors.background

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIConstants.colors.background
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(15)
            make.trailing.leading.bottom.equalTo(self.view)
        }
        
        for blockerToggle in toggles {
            let toggle = blockerToggle.toggle
            toggle.onTintColor = UIConstants.colors.toggleOn
            toggle.tintColor = UIConstants.colors.toggleOff
            toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
            toggle.isOn = Settings.getToggle(blockerToggle.setting)
        }
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        let toggle = toggles.filter { $0.toggle == sender }.first!
        
        // First check if the user changed the anonymous usage data setting and follow that choice right
        // here. Otherwise it will be delayed until the application restarts.
        if toggle.setting == .sendAnonymousUsageData {
            Telemetry.default.configuration.isCollectionEnabled = sender.isOn
            Telemetry.default.configuration.isUploadEnabled = sender.isOn
        }
        
        func updateSetting() {
            let telemetryEvent = TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.change, object: "setting", value: toggle.setting.rawValue)
            telemetryEvent.addExtra(key: "to", value: sender.isOn)
            Telemetry.default.recordEvent(telemetryEvent)
            
            Settings.set(sender.isOn, forToggle: toggle.setting)
            ContentBlockerHelper.shared.reload()
        }
        
        switch toggle.setting {
        case .blockOther where sender.isOn:
            let alertController = UIAlertController(title: nil, message: UIConstants.strings.settingsBlockOtherMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherNo, style: UIAlertActionStyle.default) { _ in
                sender.isOn = false
                updateSetting()
            })
            alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherYes, style: UIAlertActionStyle.destructive) { _ in
                updateSetting()
            })
            alertController.popoverPresentationController?.sourceView = sender
            alertController.popoverPresentationController?.sourceRect = sender.bounds
            present(alertController, animated: true, completion: nil)
        default:
            updateSetting()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toggles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "trackingToggleCell")
        let toggle = toggles[indexPath.row]
        cell.textLabel?.text = toggle.label
        cell.textLabel?.textColor = UIConstants.colors.settingsTextLabel
        cell.textLabel?.numberOfLines = 0
        cell.accessoryView = PaddedSwitch(switchView: toggle.toggle)
        cell.detailTextLabel?.text = toggle.subtitle
        cell.detailTextLabel?.textColor = UIConstants.colors.settingsDetailLabel
        cell.detailTextLabel?.numberOfLines = 0
        cell.backgroundColor = UIConstants.colors.background
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
