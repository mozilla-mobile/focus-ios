/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class TrackingProtectionToggleView: UIView {

    private let cell = UITableViewCell()
    private let icon = UIImageView(image: #imageLiteral(resourceName: "trackingprotection"))
    private let label = UILabel(frame: .zero)
    private let toggle = UISwitch()
    private let borderView = UIView()
    private let descriptionLabel = UILabel()

    convenience init() {
        self.init(frame: .zero)

        icon.tintColor = .white
        addSubview(icon)

        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = UIConstants.strings.trackingProtectionToggleLabel
        label.textColor = UIConstants.colors.trackingProtectionPrimary
        addSubview(label)

        addSubview(toggle)

        borderView.backgroundColor = UIConstants.colors.settingsSeparator
        addSubview(borderView)

        descriptionLabel.text = String(format: UIConstants.strings.trackingProtectionToggleDescription, AppInfo.productName)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIConstants.colors.trackingProtectionSecondary
        addSubview(descriptionLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        label.snp.makeConstraints {make in
            make.leading.equalTo(icon.snp.trailing).offset(08)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.trailing.equalTo(toggle.snp.leading).offset(-8)
        }

        toggle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }

        borderView.snp.makeConstraints { make in
            make.top.equalTo(toggle.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(borderView.snp.bottom).offset(8)
        }
    }
}

class TrackingProtectionSummaryView: UIView {
    fileprivate let closeButton = UIButton()
    fileprivate let toggleView = TrackingProtectionToggleView()

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIConstants.colors.background

        closeButton.setImage(#imageLiteral(resourceName: "icon_stop_menu"), for: .normal)
        addSubview(closeButton)
        addSubview(toggleView)

        setupConstraints()
    }

    private func setupConstraints() {
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        toggleView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalToSuperview().offset(76)
            make.left.right.equalToSuperview()
        }
    }
}

class TrackingProtectionSummaryViewController: UIViewController {

    override func loadView() {
        self.view = TrackingProtectionSummaryView()
    }
}
