/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class TipViewController: UIViewController {
    
    private lazy var tipTitleLabel: SmartLabel = {
        let label = SmartLabel()
        label.textColor = UIConstants.colors.defaultFont
        label.font = UIConstants.fonts.shareTrackerStatsLabel
        label.numberOfLines = 0
        label.minimumScaleFactor = UIConstants.layout.homeViewLabelMinimumScale
        return label
    }()
    
    private let tipDescriptionLabel: SmartLabel = {
        let label = SmartLabel()
        label.textColor = .accent
        label.font = UIConstants.fonts.shareTrackerStatsLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.minimumScaleFactor = UIConstants.layout.homeViewLabelMinimumScale
        return label
    }()
    
    public let tip: TipManager.Tip
    private let tipTapped: (TipManager.Tip) -> ()
    
    init(tip: TipManager.Tip, tipTapped: @escaping (TipManager.Tip) -> ()) {
        self.tip = tip
        self.tipTapped = tipTapped
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tipTitleLabel)
        view.addSubview(tipDescriptionLabel)
        
        tipDescriptionLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTip))
        tipDescriptionLabel.addGestureRecognizer(tap)

        tipTitleLabel.text = tip.title
        tipDescriptionLabel.text = tip.description
        
        tipDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(UIConstants.layout.tipDescriptionMargin)
            make.trailing.equalTo(view).inset(UIConstants.layout.tipDescriptionMargin)
            make.bottom.equalToSuperview()
        }

        tipTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(tipDescriptionLabel.snp.top)
        }
    }
    
    @objc private func tapTip() {
        tipTapped(tip)
    }
}
