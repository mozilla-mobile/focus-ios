/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Telemetry

class NewOnboardingReplaceViewController: UIViewController {
    
    //TODO: Add specific UI for Onboarding screen
    let startBrowsingButton = UIButton()
    var onboardingEventsHandler: OnboardingEventsHandler!
    let buttonWidth = 100
    let buttonHeight = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(startBrowsingButton)
        view.backgroundColor = .white
        
        startBrowsingButton.backgroundColor = .secondaryButton
        startBrowsingButton.setTitle("Start Browsing", for: .normal)
        startBrowsingButton.titleLabel?.font = .footnote14
        startBrowsingButton.setTitleColor(.white, for: .normal)
        
        startBrowsingButton.accessibilityIdentifier = "IntroViewController.button"
        startBrowsingButton.addTarget(self, action: #selector(NewOnboardingReplaceViewController.didTapStartButton), for: .touchUpInside)
        
        startBrowsingButton.snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
            make.center.equalToSuperview()
        }
    }
    
    @objc func didTapStartButton() {
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.onboarding, value: "finish")
        onboardingEventsHandler.send(.onboardingDidDismiss)
        (presentingViewController as? BrowserViewController)?.activateTextFieldAfterOnboarding()
        dismiss(animated: true)
    }
}
