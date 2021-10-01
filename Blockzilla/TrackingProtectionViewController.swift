/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import UIKit
import Telemetry
import Glean
import Combine


protocol TrackingProtectionDelegate: AnyObject {
    func trackingProtectionDidToggleProtection(enabled: Bool)
}

struct ToggleItem {
    let title: String
    let subtitle: String?
    let settingsKey: SettingsToggle
    let action: ((Bool) -> Void)?
    
    init(label: String, settingsKey: SettingsToggle, subtitle: String? = nil, action: ((Bool) -> Void)? = nil) {
        self.title = label
        self.settingsKey = settingsKey
        self.subtitle = subtitle
        self.action = action
    }
}

class SwitchTableViewCell: UITableViewCell {
    private lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .accent
        toggle.tintColor = .darkGray
        toggle.addTarget(self, action: #selector(toggle(sender:)), for: .valueChanged)
        
        return toggle
    }()
    
    var value: CurrentValueSubject<Bool, Never>!
    private var cancellable: AnyCancellable?
    
    
    convenience init(item: ToggleItem, style: UITableViewCell.CellStyle = .default, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        value = CurrentValueSubject<Bool, Never>(Settings.getToggle(item.settingsKey))
        toggle.accessibilityIdentifier = "BlockerToggle.\(item.settingsKey.rawValue)"
        self.action = item.action
        textLabel?.text = item.title
        textLabel?.textColor = .primaryText
        textLabel?.numberOfLines = 0
        accessoryView = PaddedSwitch(switchView: toggle)
        self.cancellable = value.sink { isOn in
            self.toggle.isOn = isOn
        }
            
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .secondaryBackground
        selectionStyle = .none
    }
    
    private var action: ((Bool) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func toggle(sender: UISwitch) {
        action?(sender.isOn)
        value.value = sender.isOn
    }
}

class TrackingProtectionViewController: UIViewController {
    private lazy var toggleItems = [
        ToggleItem(label: UIConstants.strings.labelBlockAds2, settingsKey: .blockAds) { isOn in
            self.updateTelemetry(.blockAds, isOn)
            GleanMetrics.TrackingProtection.trackerSettingChanged.record(.init(isEnabled: isOn, sourceOfChange: self.sourceOfChange, trackerChanged: "Advertising"))
        },
        ToggleItem(label: UIConstants.strings.labelBlockAnalytics, settingsKey: .blockAnalytics) { isOn in
            self.updateTelemetry(.blockAnalytics, isOn)
            GleanMetrics.TrackingProtection.trackerSettingChanged.record(.init(isEnabled: isOn, sourceOfChange: self.sourceOfChange, trackerChanged: "Analytics"))
        },
        ToggleItem(label: UIConstants.strings.labelBlockSocial, settingsKey: .blockSocial) { isOn in
            self.updateTelemetry(.blockSocial, isOn)
            GleanMetrics.TrackingProtection.trackerSettingChanged.record(.init(isEnabled: isOn, sourceOfChange: self.sourceOfChange, trackerChanged: "Social"))
        },
        ToggleItem(label: UIConstants.strings.labelBlockOther, settingsKey: .blockOther) { isOn in
            self.updateTelemetry(.blockOther, isOn)
            
            //            if isOn {
            //                let alertController = UIAlertController(title: nil, message: UIConstants.strings.settingsBlockOtherMessage, preferredStyle: .alert)
            //                alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherNo, style: .default) { _ in
            //                    //TODO: Make sure to reset the toggle
            ////                    isOn = false
            //                    GleanMetrics
            //                        .TrackingProtection
            //                        .trackerSettingChanged
            //                        .record(.init(isEnabled: false, sourceOfChange: self.sourceOfChange, trackerChanged: "Content")
            //                        )
            //                })
            //                alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherYes, style: .destructive) { _ in
            //                    GleanMetrics
            //                        .TrackingProtection
            //                        .trackerSettingChanged
            //                        .record(.init(isEnabled: true, sourceOfChange: self.sourceOfChange, trackerChanged: "Content")
            //                        )
            //                })
            //                self.present(alertController, animated: true, completion: nil)
            //            } else {
            //            GleanMetrics
            //                .TrackingProtection
            //                .trackerSettingChanged
            //                .record(.init(isEnabled: isOn, sourceOfChange: self.sourceOfChange, trackerChanged: "Content")
            //                )
            //            }
        },
    ]
    
    private lazy var trackingProtectionItem = ToggleItem(
        label: UIConstants.strings.trackingProtectionToggleLabel,
        settingsKey: SettingsToggle.trackingProtection) { isOn in
            self.toggleProtection(isOn: isOn)
            if isOn {
                self.profileDataSource.tableViewSections.insert(self.trackersSection, at: 1)
                self.tableView.insertSections([1], with: .middle)
            } else {
                self.profileDataSource.tableViewSections.remove(at: 1)
                self.tableView.deleteSections([1], with: .middle)
            }
        }
    
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
    lazy var enableTrackersSection = Section(
        footerTitle: trackingProtectionEnabled ? UIConstants.strings.trackingProtectionOn : UIConstants.strings.trackingProtectionOff,
        items: [
            SectionItem(
                configureCell: { tableView, indexPath in
                    let cell = SwitchTableViewCell(item: self.trackingProtectionItem, reuseIdentifier: "SwitchTableViewCell")
                    return cell
                }
            )
        ]
    )
    lazy var trackersSection = Section(
        headerTitle: UIConstants.strings.trackersHeader.uppercased(),
        items: toggleItems.map { toggleItem in
            SectionItem(
                configureCell: { tableView, indexPath in
                    let cell = SwitchTableViewCell(item: toggleItem, reuseIdentifier: "SwitchTableViewCell")
                    self.cancellable = cell.value.sink { isOn in
                        if isOn {
                            let alertController = UIAlertController(title: nil, message: UIConstants.strings.settingsBlockOtherMessage, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherNo, style: .default) { _ in
                                //TODO: Make sure to reset the toggle
                                cell.value.value = false
                                GleanMetrics
                                    .TrackingProtection
                                    .trackerSettingChanged
                                    .record(.init(isEnabled: false, sourceOfChange: self.sourceOfChange, trackerChanged: "Content")
                                    )
                            })
                            alertController.addAction(UIAlertAction(title: UIConstants.strings.settingsBlockOtherYes, style: .destructive) { _ in
                                GleanMetrics
                                    .TrackingProtection
                                    .trackerSettingChanged
                                    .record(.init(isEnabled: true, sourceOfChange: self.sourceOfChange, trackerChanged: "Content")
                                    )
                            })
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            GleanMetrics
                                .TrackingProtection
                                .trackerSettingChanged
                                .record(.init(isEnabled: isOn, sourceOfChange: self.sourceOfChange, trackerChanged: "Content")
                                )
                        }
                    }
                    return cell
                }
            )
        }
    )
    
    private var tableViewSections: [Section] {
        return trackingProtectionEnabled
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
    private var trackingProtectionEnabled: Bool {
        get {
            Settings.getToggle(trackingProtectionToggle.setting)
        }
        set {
            Settings.set(newValue, forToggle: trackingProtectionToggle.setting)
        }
    }
    
    private let trackingProtectionToggle = BlockerToggle(label: UIConstants.strings.trackingProtectionToggleLabel, setting: SettingsToggle.trackingProtection)
    
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
    
    private func statsCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "trackingStats")
        cell.textLabel?.text = String(format: UIConstants.strings.trackersBlockedSince, getAppInstallDate())
        cell.textLabel?.textColor = .primaryText.withAlphaComponent(0.6)
        cell.textLabel?.font = UIConstants.fonts.trackingProtectionStatsText
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = getNumberOfTrackersBlocked()
        cell.detailTextLabel?.textColor = .primaryText
        cell.detailTextLabel?.font = UIConstants.fonts.trackingProtectionStatsDetail
        cell.backgroundColor = .secondaryBackground
        cell.selectionStyle = .none
        return cell
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
        let toggle = trackingProtectionToggle
        let telemetryEvent = TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.change, object: "setting", value: toggle.setting.rawValue)
        telemetryEvent.addExtra(key: "to", value: isOn)
        Telemetry.default.recordEvent(telemetryEvent)
        
        GleanMetrics.TrackingProtection.trackingProtectionChanged.record(.init(isEnabled: isOn))
        GleanMetrics.TrackingProtection.hasEverChangedEtp.set(true)
        
        trackingProtectionEnabled = isOn
        
        delegate?.trackingProtectionDidToggleProtection(enabled: isOn)
    }
}
