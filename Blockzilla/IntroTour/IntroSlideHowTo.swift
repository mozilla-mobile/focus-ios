/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

protocol IntroSlideHowToDelegate: class {
    func introSlideHowToDidPressSettings(introSlideHowTo: IntroSlideHowTo)
}

class IntroSlideHowTo: UIView {
    weak var delegate: IntroSlideHowToDelegate?

    init() {
        super.init(frame: CGRectZero)

        let instructionsContainer = UIView()
        addSubview(instructionsContainer)

        let instructionsView = InstructionsView()
        addSubview(instructionsView)

        let mustBeEnabledLabel = UILabel()
        let mustBeEnabledText = NSLocalizedString("%@ must be enabled in Settings to work.", comment: "Notice label show on second introduction screen")
        mustBeEnabledLabel.text = String(format: mustBeEnabledText, AppInfo.ProductName)
        mustBeEnabledLabel.numberOfLines = 0
        mustBeEnabledLabel.textAlignment = NSTextAlignment.Center
        mustBeEnabledLabel.textColor = UIConstants.Colors.FocusOrange
        addSubview(mustBeEnabledLabel)

        let openSettingsButton = UIButton()
        openSettingsButton.setTitle(UIConstants.Strings.OpenSettings, forState: UIControlState.Normal)
        openSettingsButton.setTitleColor(UIConstants.Colors.FocusBlue, forState: UIControlState.Normal)
        openSettingsButton.setTitleColor(UIConstants.Colors.ButtonHighlightedColor, forState: UIControlState.Highlighted)
        openSettingsButton.addTarget(self, action: #selector(IntroSlideHowTo.settingsClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        openSettingsButton.titleLabel?.font = UIConstants.Fonts.DefaultFontSemibold

        addSubview(openSettingsButton)

        instructionsContainer.snp_makeConstraints { make in
            make.top.equalTo(self)
            make.bottom.equalTo(mustBeEnabledLabel.snp_top)
            make.leading.trailing.equalTo(self)
        }

        instructionsView.snp_makeConstraints { make in
            make.center.equalTo(instructionsContainer)
            make.width.equalTo(220)
        }

        openSettingsButton.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-70)
        }

        mustBeEnabledLabel.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(30)
            make.bottom.equalTo(openSettingsButton.snp_top).offset(-30)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func settingsClicked(sender: UIButton) {
        delegate?.introSlideHowToDidPressSettings(self)
    }
}