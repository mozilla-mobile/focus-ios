/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

protocol HomeViewDelegate: class {
    func shareTrackerStatsButtonTapped()
    func tipTapped()
}

class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    private let description1 = SmartLabel()
    private let description2 = SmartLabel()
    private let tipView = UIView()
    private let trackerStatsLabel = SmartLabel()
    private let tipTitleLabel = SmartLabel()
    private let tipDescriptionLabel = SmartLabel()
    private let shieldLogo = UIImageView()
    
    let toolbar = HomeViewToolbar()
    let trackerStatsShareButton = UIButton()
    var tipManager: TipManager? {
        didSet {
            if let tipManager = tipManager, let tip = tipManager.fetchTip() {
                showTipView()
                switch tip.identifier {
                case TipManager.TipKey.shareTrackersTip:
                    hideTextTip()
                    let numberOfTrackersBlocked = UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey)
                    showTrackerStatsShareButton(text: String(format: tip.title, String(numberOfTrackersBlocked)))
                default:
                    hideTrackerStatsShareButton()
                    showTextTip(tip)
                }
                tipManager.currentTip = tip
            }
        }
    }
            
    
    init() {
        super.init(frame: CGRect.zero)

        let wordmark = AppInfo.config.wordmark
        let textLogo = UIImageView(image: wordmark)
        addSubview(textLogo)

        description1.textColor = .white
        description1.font = UIConstants.fonts.homeLabel
        description1.textAlignment = .center
        description1.text = UIConstants.strings.homeLabel1
        description1.numberOfLines = 0
        addSubview(description1)

        description2.textColor = .white
        description2.font = UIConstants.fonts.homeLabel
        description2.textAlignment = .center
        description2.text = UIConstants.strings.homeLabel2
        description2.numberOfLines = 0
        addSubview(description2)
        
        addSubview(toolbar)
        
        addSubview(tipView)
        tipView.isHidden = true
        
        tipTitleLabel.textColor = UIConstants.colors.defaultFont
        tipTitleLabel.font = UIConstants.fonts.shareTrackerStatsLabel
        tipTitleLabel.numberOfLines = 0
        tipTitleLabel.minimumScaleFactor = 0.65
        tipView.addSubview(tipTitleLabel)
        
        tipDescriptionLabel.textColor = UIConstants.colors.defaultFont
        tipDescriptionLabel.font = UIConstants.fonts.shareTrackerStatsLabel
        tipDescriptionLabel.numberOfLines = 0
        tipDescriptionLabel.minimumScaleFactor = 0.65
        tipView.addSubview(tipDescriptionLabel)

        shieldLogo.image = #imageLiteral(resourceName: "tracking_protection")
        shieldLogo.tintColor = UIColor.white
        tipView.addSubview(shieldLogo)
        
        trackerStatsLabel.font = UIConstants.fonts.shareTrackerStatsLabel
        trackerStatsLabel.textColor = UIConstants.colors.defaultFont
        trackerStatsLabel.numberOfLines = 0
        trackerStatsLabel.minimumScaleFactor = 0.65
        tipView.addSubview(trackerStatsLabel)
        
        trackerStatsShareButton.setTitleColor(UIConstants.colors.defaultFont, for: .normal)
        trackerStatsShareButton.titleLabel?.font = UIConstants.fonts.shareTrackerStatsLabel
        trackerStatsShareButton.titleLabel?.textAlignment = .center
        trackerStatsShareButton.setTitle(UIConstants.strings.share, for: .normal)
        trackerStatsShareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        trackerStatsShareButton.titleLabel?.numberOfLines = 0
        trackerStatsShareButton.layer.borderColor = UIConstants.colors.defaultFont.cgColor
        trackerStatsShareButton.layer.borderWidth = 1.0;
        trackerStatsShareButton.layer.cornerRadius = 4
        tipView.addSubview(trackerStatsShareButton)

        textLogo.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(snp.centerY).offset(UIConstants.layout.textLogoOffset)
        }

        description1.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(textLogo.snp.bottom).offset(25)
        }

        description2.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(description1.snp.bottom).offset(UIConstants.layout.homeViewTextOffset)
        }
        
        tipView.snp.makeConstraints { make in
            make.bottom.equalTo(toolbar.snp.top).offset(UIConstants.layout.shareTrackersBottomOffset)
            make.height.equalTo(UIConstants.layout.shareTrackersHeight)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(280)
            make.width.lessThanOrEqualToSuperview().offset(-32)
        }
        
        tipDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tipTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tipDescriptionLabel.snp.top).offset(-UIConstants.layout.homeViewTextOffset)
        }
        
        toolbar.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().priority(.required)
        }
        
        trackerStatsShareButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(80).priority(500)
            make.width.greaterThanOrEqualTo(50)
            make.height.equalToSuperview()
        }
        
        trackerStatsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(trackerStatsShareButton.snp.centerY)
            make.left.equalTo(shieldLogo.snp.right).offset(8)
            make.right.equalTo(trackerStatsShareButton.snp.left).offset(-13)
            make.height.equalToSuperview()
        }
        
        shieldLogo.snp.makeConstraints { make in
            make.centerY.equalTo(trackerStatsShareButton.snp.centerY)
            make.left.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showTipView() {
        description1.isHidden = true
        description2.isHidden = true
        tipView.isHidden = false
    }
    
    func showTrackerStatsShareButton(text: String) {
        trackerStatsLabel.text = text
        trackerStatsLabel.sizeToFit()
        trackerStatsLabel.isHidden = false
        trackerStatsShareButton.isHidden = false
        shieldLogo.isHidden = false
    }
    
    func hideTrackerStatsShareButton() {
        shieldLogo.isHidden = true
        trackerStatsLabel.isHidden = true
        trackerStatsShareButton.isHidden = true
    }
    
    func showTextTip(_ tip: TipManager.Tip) {
        tipTitleLabel.text = tip.title
        tipTitleLabel.sizeToFit()
        tipTitleLabel.isHidden = false
        if let description = tip.description, tip.showVc {
            tipDescriptionLabel.attributedText = NSAttributedString(string: description, attributes:
                [.underlineStyle: NSUnderlineStyle.single.rawValue])
            tipDescriptionLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(HomeView.tapTip))
            tipDescriptionLabel.addGestureRecognizer(tap)
        } else {
            tipDescriptionLabel.text = tip.description
            tipDescriptionLabel.isUserInteractionEnabled = false
        }
        tipDescriptionLabel.sizeToFit()
        tipDescriptionLabel.isHidden = false
    }
    
    func hideTextTip() {
        tipTitleLabel.isHidden = true
        tipDescriptionLabel.isHidden = true
    }
        
    
    @objc private func shareTapped() {
        delegate?.shareTrackerStatsButtonTapped()
    }
    
    @objc private func tapTip() {
        delegate?.tipTapped()
    }
}
