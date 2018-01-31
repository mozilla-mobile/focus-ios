/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

protocol HomeViewDelegate: class {
    func homeViewDidPressSettings(homeView: HomeView)
    func shareTrackerStatsButtonTapped()
}

class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    private(set) var settingsButton: UIButton! = nil
    private let trackerStatsShareButton = UIButton()

    init() {
        super.init(frame: CGRect.zero)

        let wordmark = AppInfo.config.wordmark
        let textLogo = UIImageView(image: wordmark)
        addSubview(textLogo)

        let description1 = UILabel()
        description1.textColor = .white
        description1.font = UIConstants.fonts.homeLabel
        description1.textAlignment = .center
        description1.text = UIConstants.strings.homeLabel1
        description1.numberOfLines = 0
        addSubview(description1)

        let description2 = UILabel()
        description2.textColor = .white
        description2.font = UIConstants.fonts.homeLabel
        description2.textAlignment = .center
        description2.text = UIConstants.strings.homeLabel2
        description2.numberOfLines = 0
        addSubview(description2)

        let settingsButton = UIButton()
        settingsButton.setImage(#imageLiteral(resourceName: "icon_settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(didPressSettings), for: .touchUpInside)
        settingsButton.accessibilityLabel = UIConstants.strings.browserSettings
        settingsButton.accessibilityIdentifier = "HomeView.settingsButton"
        addSubview(settingsButton)
        self.settingsButton = settingsButton
        
        trackerStatsShareButton.isHidden = true
        trackerStatsShareButton.setTitleColor(.white, for: .normal)
        trackerStatsShareButton.titleLabel?.font = UIConstants.fonts.homeLabel
        trackerStatsShareButton.titleLabel?.textAlignment = .center
        trackerStatsShareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        trackerStatsShareButton.titleLabel?.numberOfLines = 0
        addSubview(trackerStatsShareButton)

        textLogo.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(snp.centerY).offset(-10)
        }

        description1.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(textLogo.snp.bottom).offset(25)
        }

        description2.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(description1.snp.bottom).offset(5)
        }

        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(self).offset(15)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(16)
            make.height.width.equalTo(24)
        }
        
        trackerStatsShareButton.snp.makeConstraints { make in
            make.top.equalTo(description2.snp.bottom).offset(20)
            make.height.equalTo(20)
            make.width.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didPressSettings() {
        delegate?.homeViewDidPressSettings(homeView: self)
    }
    
    func showTrackerStatsShareButton(text: String) {
        trackerStatsShareButton.setTitle(text, for: .normal)
        trackerStatsShareButton.isHidden = false
    }
    
    func hideTrackerStatsShareButton() {
        trackerStatsShareButton.isHidden = true
    }
    
    @objc private func shareTapped() {
        delegate?.shareTrackerStatsButtonTapped()
    }
    
    func setHighlightWhatsNew(shouldHighlight: Bool) {
        if shouldHighlight {
            settingsButton.setImage(UIImage(named: "preferences_updated"), for: .normal)
        } else {
            settingsButton.setImage(#imageLiteral(resourceName: "icon_settings"), for: .normal)
        }
    }
}
