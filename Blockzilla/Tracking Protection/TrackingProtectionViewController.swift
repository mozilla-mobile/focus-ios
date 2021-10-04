/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import UIKit
import Telemetry
import Glean
import Combine

class TrackingProtectionViewController: UIViewController {
    private lazy var toggleItems = [
        ToggleItem(label: UIConstants.strings.labelBlockAds2, settingsKey: .blockAds),
        ToggleItem(label: UIConstants.strings.labelBlockAnalytics, settingsKey: .blockAnalytics),
        ToggleItem(label: UIConstants.strings.labelBlockSocial, settingsKey: .blockSocial),
    ]
    let blockOtherItem = ToggleItem(label: UIConstants.strings.labelBlockOther, settingsKey: .blockOther)
    
    private lazy var trackingProtectionItem = ToggleItem(
        label: UIConstants.strings.trackingProtectionToggleLabel,
        settingsKey: SettingsToggle.trackingProtection)
    
    private lazy var profileDataSource = DataSource(tableViewSections: tableViewSections)
    lazy var statsSection = Section(
        items: [
            SectionItem(
                configureCell: { _, _ in
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "trackingStats")
                    cell.textLabel?.text = String(format: UIConstants.strings.trackersBlockedSince, self.getAppInstallDate())
                    cell.textLabel?.textColor = .primaryText.withAlphaComponent(0.6)
                    cell.textLabel?.font = UIConstants.fonts.trackingProtectionStatsText
                    cell.textLabel?.numberOfLines = 0
                    cell.detailTextLabel?.text = self.getNumberOfTrackersBlocked()
                    cell.detailTextLabel?.textColor = .primaryText
                    cell.detailTextLabel?.font = UIConstants.fonts.trackingProtectionStatsDetail
                    cell.backgroundColor = .secondaryBackground
                    cell.selectionStyle = .none
                    return cell
                }
            )
        ]
    )
    
    private var subscriptions = Set<AnyCancellable>()
    lazy var enableTrackersSection = Section(
        footerTitle: trackingProtectionItem.settingsValue ? UIConstants.strings.trackingProtectionOn : UIConstants.strings.trackingProtectionOff,
        items: [
            SectionItem(
                configureCell: { [unowned self] tableView, indexPath in
                    let cell = SwitchTableViewCell(
                        item: self.trackingProtectionItem,
                        reuseIdentifier: "SwitchTableViewCell"
                    )
                    cell.valueChanged.sink { isOn in
                        self.trackingProtectionItem.settingsValue = isOn
                        self.toggleProtection(isOn: isOn)
                        if isOn {
                            self.profileDataSource.tableViewSections.insert(self.trackersSection, at: 1)
                            self.tableView.insertSections([1], with: .middle)
                        } else {
                            self.profileDataSource.tableViewSections.remove(at: 1)
                            self.tableView.deleteSections([1], with: .middle)
                        }
                        self.calculatePreferredSize()
                    }
                    .store(in: &self.subscriptions)
                    return cell
                }
            )
        ]
    )
    
    lazy var trackersSection = Section(
        headerTitle: UIConstants.strings.trackersHeader.uppercased(),
        items: toggleItems.map { toggleItem in
            SectionItem(
                configureCell: { [unowned self] _, _ in
                    let cell = SwitchTableViewCell(item: toggleItem, reuseIdentifier: "SwitchTableViewCell")
                    cell.valueChanged.sink { isOn in
                        toggleItem.settingsValue = isOn
                        self.updateTelemetry(toggleItem.settingsKey, isOn)
                        
                        GleanMetrics
                            .TrackingProtection
                            .trackerSettingChanged
                            .record(.init(
                                isEnabled: isOn,
                                sourceOfChange: self.sourceOfChange,
                                trackerChanged: toggleItem.settingsKey.trackerChanged)
                            )
                        
                        if toggleItem.settingsKey == .blockOther, isOn { }
                    }
                    .store(in: &self.subscriptions)
                    return cell
                }
            )
        }
        +
        [
            SectionItem(
                configureCell: { [unowned self] _, _ in
                    let cell = SwitchTableViewCell(item: blockOtherItem, reuseIdentifier: "SwitchTableViewCell")
                    cell.valueChanged.sink { isOn in
                        if isOn {
                            let alertController = UIAlertController(title: nil, message: UIConstants.strings.settingsBlockOtherMessage, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherNo, style: .default) { _ in
                                //TODO: Make sure to reset the toggle
                                cell.isOn = false
                                blockOtherItem.settingsValue = false
                                self.updateTelemetry(blockOtherItem.settingsKey, false)
                                GleanMetrics
                                    .TrackingProtection
                                    .trackerSettingChanged
                                    .record(.init(
                                        isEnabled: false,
                                        sourceOfChange: self.sourceOfChange,
                                        trackerChanged: blockOtherItem.settingsKey.trackerChanged
                                    ))
                            })
                            alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherYes, style: .destructive) { _ in
                                blockOtherItem.settingsValue = true
                                self.updateTelemetry(blockOtherItem.settingsKey, true)
                                GleanMetrics
                                    .TrackingProtection
                                    .trackerSettingChanged
                                    .record(.init(
                                        isEnabled: true,
                                        sourceOfChange: self.sourceOfChange,
                                        trackerChanged: blockOtherItem.settingsKey.trackerChanged
                                    ))
                            })
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            blockOtherItem.settingsValue = isOn
                            updateTelemetry(blockOtherItem.settingsKey, isOn)
                            GleanMetrics
                                .TrackingProtection
                                .trackerSettingChanged
                                .record(.init(
                                    isEnabled: isOn,
                                    sourceOfChange: self.sourceOfChange,
                                    trackerChanged: blockOtherItem.settingsKey.trackerChanged
                                ))
                        }
                    }
                    .store(in: &self.subscriptions)
                    return cell
                }
            )
        ]
    )
    
    private var tableViewSections: [Section] {
        return trackingProtectionItem.settingsValue
        ? [enableTrackersSection, trackersSection, statsSection]
        : [enableTrackersSection, statsSection]
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = profileDataSource
        tableView.dataSource = profileDataSource
        tableView.backgroundColor = .primaryBackground
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(SwitchTableViewCell.self)
        return tableView
    }()
    
    private var modalDelegate: ModalDelegate?
    private var isOpenedFromSetting = false
    private var sourceOfChange: String { isOpenedFromSetting ? "Settings" : "Panel" }
    weak var delegate: TrackingProtectionDelegate?
    
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isOpenedFromSetting = self.navigationController?.viewControllers.count != 1
        
        view.backgroundColor = .primaryBackground
        title = UIConstants.strings.trackingProtectionLabel
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
        navigationController?.navigationBar.tintColor = .accent
        
        if !isOpenedFromSetting {
            let doneButton = UIBarButtonItem(title: UIConstants.strings.done, style: .plain, target: self, action: #selector(doneTapped))
            doneButton.tintColor = .accent
            navigationItem.rightBarButtonItem = doneButton
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.layoutIfNeeded()
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.barTintColor = .primaryBackground
        }
        
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(15)
            make.leading.trailing.equalTo(self.view).inset(UIConstants.layout.trackingProtectionTableInset)
            make.bottom.equalTo(self.view)
        }
    }
    
    private func calculatePreferredSize() {
        preferredContentSize = tableView.contentSize
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      calculatePreferredSize()
    }
    
    override func viewWillLayoutSubviews() {
        updateHorizontalConstraintsForTableView()
    }
    
    private func updateHorizontalConstraintsForTableView() {
        tableView.snp.updateConstraints { make in
            switch (UIDevice.current.userInterfaceIdiom, UIDevice.current.orientation) {
            case (.phone, .landscapeLeft):
                make.leading.equalTo(view).offset(view.safeAreaInsets.left)
                make.trailing.equalTo(view).inset(UIConstants.layout.trackingProtectionTableInset)
            case (.phone, .landscapeRight):
                make.leading.equalTo(view).inset(UIConstants.layout.trackingProtectionTableInset)
                make.trailing.equalTo(view).inset(view.safeAreaInsets.right)
            default:
                make.leading.trailing.equalTo(view).inset(UIConstants.layout.trackingProtectionTableInset)
            }
        }
    }
    
    @objc private func doneTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func updateTelemetry(_ settingsKey: SettingsToggle, _ isOn: Bool) {
        let telemetryEvent = TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.change, object: "setting", value: settingsKey.rawValue)
        telemetryEvent.addExtra(key: "to", value: isOn)
        Telemetry.default.recordEvent(telemetryEvent)
        
        Settings.set(isOn, forToggle: settingsKey)
        ContentBlockerHelper.shared.reload()
    }
    
    private func getAppInstallDate() -> String {
        let urlToDocumentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let installDate = (try! FileManager.default.attributesOfItem(atPath: urlToDocumentsFolder.path)[FileAttributeKey.creationDate]) as? Date {
            let stringDate = dateFormatter.string(from: installDate)
            return stringDate
        }
        return dateFormatter.string(from: Date())
    }
    
    private func getNumberOfTrackersBlocked() -> String {
        let numberOfTrackersBlocked = NSNumber(integerLiteral: UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey))
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: numberOfTrackersBlocked) ?? "0"
    }
    
    private func toggleProtection(isOn: Bool) {
        let telemetryEvent = TelemetryEvent(
            category: TelemetryEventCategory.action,
            method: TelemetryEventMethod.change,
            object: "setting",
            value: SettingsToggle.trackingProtection.rawValue
        )
        telemetryEvent.addExtra(key: "to", value: isOn)
        Telemetry.default.recordEvent(telemetryEvent)
        
        GleanMetrics.TrackingProtection.trackingProtectionChanged.record(.init(isEnabled: isOn))
        GleanMetrics.TrackingProtection.hasEverChangedEtp.set(true)
        
        delegate?.trackingProtectionDidToggleProtection(enabled: isOn)
    }
}
