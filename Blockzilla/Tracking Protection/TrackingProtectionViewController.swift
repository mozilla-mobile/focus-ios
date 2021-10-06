/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import UIKit
import Telemetry
import Glean
import Combine

struct SecureConnectionStatus {
    let url: URL
    let isSecureConnection: Bool
}

extension SecureConnectionStatus {
    var faviconURL: URL? {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.path = "/favicon.ico"
        return components?.url
    }
}

enum TrackingProtectionState {
    case browsing(status: SecureConnectionStatus)
    case homescreen
    case settings
}

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
    
    private lazy var profileDataSource = DataSource(tableViewSections: tableViewSections.compactMap { $0 })
    
    var state: TrackingProtectionState
    init(state: TrackingProtectionState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func secureConnectionSection(title: String, image: UIImage) -> Section {
        return Section(
            items: [
                SectionItem(
                    configureCell: { _, _ in
                        return ImageCell(image: image, title: title)
                    }
                )
            ]
        )
    }
    
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
    
    var trackersSectionIndex: Int {
        if case .browsing = state { return 2 }  else { return 1 }
    }
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
                            self.profileDataSource.tableViewSections.insert(self.trackersSection, at: trackersSectionIndex)
                            self.tableView.insertSections([trackersSectionIndex], with: .middle)
                        } else {
                            self.profileDataSource.tableViewSections.remove(at: trackersSectionIndex)
                            self.tableView.deleteSections([trackersSectionIndex], with: .middle)
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
    
    private var tableViewSections: [Section?] {
        let secureSection: Section?
        if case let .browsing(browsingStatus) = state {
            let title = browsingStatus.isSecureConnection ? UIConstants.strings.connectionSecure : UIConstants.strings.connectionNotSecure
            let image = browsingStatus.isSecureConnection ? UIImage.connectionSecure : .connectionNotSecure
            secureSection = secureConnectionSection(title: title, image: image)
        } else {
            secureSection = nil
        }
        return [
            secureSection,
            enableTrackersSection,
            trackingProtectionItem.settingsValue ? trackersSection : nil,
            statsSection
        ]
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
    private var sourceOfChange: String {
        if case .settings = state { return "Settings" }  else { return "Panel" }
    }
    weak var delegate: TrackingProtectionDelegate?
    
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .primaryBackground
        title = UIConstants.strings.trackingProtectionLabel
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
        navigationController?.navigationBar.tintColor = .accent
        
        if case .settings = state {
            let doneButton = UIBarButtonItem(title: UIConstants.strings.done, style: .plain, target: self, action: #selector(doneTapped))
            doneButton.tintColor = .accent
            navigationItem.rightBarButtonItem = doneButton
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.layoutIfNeeded()
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.barTintColor = .primaryBackground
        }
        
        view.addSubview(header)
        header.snp.makeConstraints { make in
            self.headerHeight = make.height.equalTo(72).constraint
            make.leading.top.trailing.equalToSuperview()
        }
        if case let .browsing(browsingStatus) = state,
           let baseDomain = browsingStatus.url.baseDomain,
           let url = browsingStatus.faviconURL {
            header.configure(domain: baseDomain, imageURL: url)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom)
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    private var headerHeight: Constraint!
    
    lazy var header: TrackingHeaderView = {
        let header = TrackingHeaderView()
        return header
    }()
    
    private func calculatePreferredSize() {
        preferredContentSize = CGSize(
            width: tableView.contentSize.width,
            height: tableView.contentSize.height + headerHeight.layoutConstraints[0].constant
        )
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.presentingViewController?.presentedViewController?.preferredContentSize = CGSize(
                width: tableView.contentSize.width,
                height: tableView.contentSize.height + headerHeight.layoutConstraints[0].constant
            )
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize()
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
