/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Telemetry
import SnapKit

protocol HomeViewDelegate: class {
    func shareTrackerStatsButtonTapped(_ sender: UIButton)
    func didTapTip(_ tip: TipManager.Tip)
}

class HomeViewController: UIViewController {
    
    weak var delegate: HomeViewDelegate?
    private let tipView = UIView()
    
    private lazy var textLogo: UIImageView = {
        let textLogo = UIImageView()
        textLogo.image = AppInfo.isKlar ? #imageLiteral(resourceName: "img_klar_wordmark") : #imageLiteral(resourceName: "img_focus_wordmark")
        textLogo.contentMode = .scaleAspectFit
        return textLogo
    }()
    
    private let tipManager: TipManager
    private let tipsViewController: TipsPageViewController
    
    public var tipViewTop: ConstraintItem { tipView.snp.top }

    let toolbar = HomeViewToolbar()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(tipManager: TipManager) {
        self.tipManager = tipManager
        self.tipsViewController = TipsPageViewController(tipManager: tipManager)
        super.init(nibName: nil, bundle: nil)
        
        
        rotated()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)

        view.addSubview(textLogo)
        view.addSubview(toolbar)
        view.addSubview(tipView)

        textLogo.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view.snp.centerY).offset(UIConstants.layout.textLogoOffset)
            make.left.equalTo(self.view.snp.left).offset(UIConstants.layout.textLogoMargin)
            make.right.equalTo(self.view.snp.left).offset(-UIConstants.layout.textLogoMargin)
        }

        tipView.snp.makeConstraints { make in
            make.bottom.equalTo(toolbar.snp.top).offset(-6)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(75)
        }

        toolbar.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }

        refreshTipsDisplay()
        install(tipsViewController, on: tipView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshTipsDisplay() {
        if let tip = tipManager.fetchTip() {
            showTextTip(tip)
            
            tipManager.currentTip = tip
            tipsViewController.setupPageController(with: .showTips)
        } else if tipManager.shouldShowTips() {
            tipManager.currentTip = nil
            tipsViewController.setupPageController(
                with: .showEmpty(
                    controller: ShareTrackersViewController(
                        trackerTitle: tipManager.shareTrackersDescription(),
                        shareTap: { [weak self] sender in
                            self?.delegate?.shareTrackerStatsButtonTapped(sender)
                        }
                    )))
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.show, object: TelemetryEventObject.trackerStatsShareButton)
        }
    }

    @objc private func rotated() {
        if UIApplication.shared.orientation?.isLandscape == true {
            hideTextLogo()
        } else {
            showTextLogo()
        }
    }

    private func hideTextLogo() {
        textLogo.isHidden = true
    }

    private func showTextLogo() {
        textLogo.isHidden = false
    }

    func showTextTip(_ tip: TipManager.Tip) {

        switch tip.identifier {
        case TipManager.TipKey.biometricTip:
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.show, object: TelemetryEventObject.biometricTip)
        case TipManager.TipKey.requestDesktopTip:
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.show, object: TelemetryEventObject.requestDesktopTip)
        case TipManager.TipKey.siriEraseTip:
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.show, object: TelemetryEventObject.siriEraseTip)
        case TipManager.TipKey.siriFavoriteTip:
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.show, object: TelemetryEventObject.siriFavoriteTip)
        case TipManager.TipKey.sitesNotWorkingTip:
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.show, object: TelemetryEventObject.sitesNotWorkingTip)
        default:
            break
        }
    }

    @objc private func tapTip() {
        guard let tip = tipManager.currentTip else { return }
        delegate?.didTapTip(tip)
    }
}
