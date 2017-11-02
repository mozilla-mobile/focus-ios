/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

private extension BlockLists.List {
    var labelText: String {
        switch self {
        case .advertising: return UIConstants.strings.adTrackerLabel
        case .analytics: return UIConstants.strings.analyticTrackerLabel
        case .social: return UIConstants.strings.socialTrackerLabel
        case .content: return UIConstants.strings.contentTrackerLabel
        }
    }

    var color: UIColor {
        switch self {
        case .advertising: return UIColor(rgb: 0x8000D7)
        case .analytics: return UIColor(rgb: 0xED00B5)
        case .social: return UIColor(rgb: 0xD7B600)
        case .content: return UIColor(rgb: 0x00C8D7)
        }
    }
}

protocol TrackingProtectionSummaryDelegate: class {
    func trackingProtectionSummaryControllerDidTapClose(_ controller: TrackingProtectionSummaryViewController)
}

class TrackingProtectionBreakdownVisualizer: UIView {
    private let adSection = UIView()
    private let analyticSection = UIView()
    private let socialSection = UIView()
    private let contentSection = UIView()

    private var adWidth: Constraint!
    private var analyticWidth: Constraint!
    private var socialWidth: Constraint!
    private var contentWidth: Constraint!

    var trackingProtectionStatus = TrackingProtectionStatus.off {
        didSet {
            render(status: trackingProtectionStatus)
        }
    }

    convenience init() {
        self.init(frame: .zero)

        backgroundColor = UIConstants.colors.trackingProtectionBreakdownBackground

        adSection.backgroundColor = BlockLists.List.advertising.color
        addSubview(adSection)

        analyticSection.backgroundColor = BlockLists.List.analytics.color
        addSubview(analyticSection)

        socialSection.backgroundColor = BlockLists.List.social.color
        addSubview(socialSection)

        contentSection.backgroundColor = BlockLists.List.content.color
        addSubview(contentSection)

        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeVisualizerSegmetns()
    }

    private func render(status: TrackingProtectionStatus) {
        switch status {
        case .on(let info):
            adSection.isHidden = false
            analyticSection.isHidden = false
            socialSection.isHidden = false
            contentSection.isHidden = false
            resizeVisualizerSegmetns()
        case .off:
            adSection.isHidden = true
            analyticSection.isHidden = true
            socialSection.isHidden = true
            contentSection.isHidden = true
        }
    }
    
    private func resizeVisualizerSegmetns() {
        guard case .on(let info) = trackingProtectionStatus else { return }
        let total = CGFloat(info.total)
        guard total > 0 else { return }
        let width = frame.width
        adWidth.update(offset: width * (CGFloat(info.adCount) / total))
        analyticWidth.update(offset: width * (CGFloat(info.analyticCount) / total))
        contentWidth.update(offset: width * (CGFloat(info.contentCount) / total))
        socialWidth.update(offset: width * (CGFloat(info.socialCount) / total))
    }
 
    private func setupConstraints() {
        adSection.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            self.adWidth = make.width.equalTo(0).constraint
            make.leading.equalToSuperview()
        }

        analyticSection.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            self.analyticWidth = make.width.equalTo(0).constraint
            make.leading.equalTo(adSection.snp.trailing)
        }

        socialSection.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            self.socialWidth = make.width.equalTo(0).constraint
            make.leading.equalTo(analyticSection.snp.trailing)
        }

        contentSection.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            self.contentWidth = make.width.equalTo(0).constraint
            make.leading.equalTo(socialSection.snp.trailing)
            make.trailing.equalToSuperview().priority(500)
        }
    }
}

class TrackingProtectionBreakdownItem: UIView {
    private let indicatorView = UIView()
    private let titleLabel = UILabel()
    private let counterLabel = UILabel()

    override var intrinsicContentSize: CGSize { return CGSize(width: 0, height: 56) }

    convenience init(text: String, color: UIColor) {
        self.init(frame: .zero)

        indicatorView.backgroundColor = color
        indicatorView.layer.cornerRadius = 4
        addSubview(indicatorView)

        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIConstants.colors.trackingProtectionPrimary
        addSubview(titleLabel)

        counterLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        counterLabel.textColor = UIConstants.colors.trackingProtectionPrimary
        addSubview(counterLabel)

        indicatorView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(-4)
            make.width.equalTo(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(indicatorView.snp.centerY)
            make.leading.equalTo(indicatorView.snp.trailing).offset(12)
        }

        counterLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    func setCounter(to value: Int) {
        counterLabel.text = String(value)
    }
}

class TrackingProtectionBreakdownView: UIView {
    private let titleLabel = UILabel()
    private let counterLabel = UILabel()
    private let breakdown = TrackingProtectionBreakdownVisualizer()
    private let adItem = TrackingProtectionBreakdownItem(text: UIConstants.strings.adTrackerLabel, color: BlockLists.List.advertising.color)
    private let analyticItem = TrackingProtectionBreakdownItem(text: UIConstants.strings.analyticTrackerLabel, color: BlockLists.List.analytics.color)
    private let contentItem = TrackingProtectionBreakdownItem(text: UIConstants.strings.contentTrackerLabel, color: BlockLists.List.content.color)
    private let socialItem = TrackingProtectionBreakdownItem(text: UIConstants.strings.socialTrackerLabel, color: BlockLists.List.social.color)
    private var stackView: UIStackView?

    var trackingProtectionStatus = TrackingProtectionStatus.off {
        didSet {
            breakdown.trackingProtectionStatus = trackingProtectionStatus
            if case .on(let info) = trackingProtectionStatus {
                titleLabel.text = UIConstants.strings.trackersBlocked
                counterLabel.text = String(info.total)

                adItem.setCounter(to: info.adCount)
                analyticItem.setCounter(to: info.analyticCount)
                contentItem.setCounter(to: info.contentCount)
                socialItem.setCounter(to: info.socialCount)
            } else {
                titleLabel.text = UIConstants.strings.trackingProtectionDisabledLabel
                counterLabel.text = ""
            }
        }
    }

    convenience init() {
        self.init(frame: .zero)

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIConstants.colors.trackingProtectionPrimary
        titleLabel.text = UIConstants.strings.trackersBlocked
        addSubview(titleLabel)

        counterLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        counterLabel.textColor = UIConstants.colors.trackingProtectionPrimary
        addSubview(counterLabel)
        
        addSubview(breakdown)

        let stackView = UIStackView(arrangedSubviews: [adItem, analyticItem, socialItem, contentItem])
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        self.stackView = stackView

        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.top.equalToSuperview()
            make.leading.equalTo(safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(counterLabel.snp.leading)
        }

        counterLabel.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
        }

        breakdown.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(titleLabel.snp.bottom)
        }

        stackView?.snp.makeConstraints { make in
            make.top.equalTo(breakdown.snp.bottom).offset(8)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }

        stackView?.arrangedSubviews.forEach { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }
    }
}

class TrackingProtectionToggleView: UIView {
    private let icon = UIImageView(image: #imageLiteral(resourceName: "tracking_protection"))
    private let label = UILabel(frame: .zero)
    private let toggle = UISwitch()
    private let borderView = UIView()
    private let descriptionLabel = UILabel()


    var trackingProtectionStatus = TrackingProtectionStatus.off {
        didSet {
            switch trackingProtectionStatus {
            case .on: toggle.isOn = true
            case .off: toggle.isOn = false
            }
        }
    }

    convenience init() {
        self.init(frame: .zero)

        icon.tintColor = .white
        addSubview(icon)

        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = UIConstants.strings.trackingProtectionToggleLabel
        label.textColor = UIConstants.colors.trackingProtectionPrimary
        addSubview(label)

        toggle.onTintColor = UIConstants.colors.toggleOn
        addSubview(toggle)

        borderView.backgroundColor = UIConstants.colors.settingsSeparator
        addSubview(borderView)

        descriptionLabel.text = String(format: UIConstants.strings.trackingProtectionToggleDescription, AppInfo.productName)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIConstants.colors.trackingProtectionSecondary
        descriptionLabel.numberOfLines = 0
        addSubview(descriptionLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.leading.equalTo(safeAreaLayoutGuide).offset(16)
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
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-16)
        }

        borderView.snp.makeConstraints { make in
            make.top.equalTo(toggle.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(borderView.snp.bottom).offset(8)
        }
    }
}

class TrackingProtectionView: UIView {
    fileprivate let closeButton = UIButton()
    fileprivate let toggleView = TrackingProtectionToggleView()
    fileprivate let breakdownView = TrackingProtectionBreakdownView()

    var trackingProtectionStatus = TrackingProtectionStatus.off {
        didSet {
            toggleView.trackingProtectionStatus = trackingProtectionStatus
            breakdownView.trackingProtectionStatus = trackingProtectionStatus
        }
    }

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIConstants.colors.background

        closeButton.setImage(#imageLiteral(resourceName: "icon_stop_menu"), for: .normal)
        addSubview(closeButton)
        addSubview(toggleView)
        addSubview(breakdownView)

        setupConstraints()
    }

    private func setupConstraints() {
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        toggleView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalTo(safeAreaLayoutGuide).offset(76)
            make.left.right.equalToSuperview()
        }

        breakdownView.snp.makeConstraints { make in
            make.top.equalTo(toggleView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
    }
}

class TrackingProtectionSummaryViewController: UIViewController {
    weak var delegate: TrackingProtectionSummaryDelegate?
    
    var trackingProtectionStatus = TrackingProtectionStatus.on(TrackingInformation()) {
        didSet {
            trackingProtectionView.trackingProtectionStatus = trackingProtectionStatus
        }
    }

    private let trackingProtectionView = TrackingProtectionView()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        trackingProtectionView.closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    override func loadView() {
        self.view = trackingProtectionView
    }

    @objc private func didTapClose() {
        delegate?.trackingProtectionSummaryControllerDidTapClose(self)
    }
}
