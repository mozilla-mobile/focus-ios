/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

protocol HomeViewDelegate: class {
    func homeViewDidPressSettings(homeView: HomeView)
}

class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    private(set) var settingsButton: UIButton! = nil

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
        settingsButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 4, bottom: 14, right: 16)
        settingsButton.addTarget(self, action: #selector(didPressSettings), for: .touchUpInside)
        settingsButton.accessibilityLabel = UIConstants.strings.browserSettings
        settingsButton.accessibilityIdentifier = "HomeView.settingsButton"
        addSubview(settingsButton)
        self.settingsButton = settingsButton

        textLogo.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(snp.centerY).offset(-10)
        }

        description1.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(textLogo.snp.bottom).offset(30)
        }

        description2.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(description1.snp.bottom).offset(5)
        }

        settingsButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(self)
            make.height.equalTo(52)
            make.width.equalTo(40)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didPressSettings() {
        delegate?.homeViewDidPressSettings(homeView: self)
    }
}
