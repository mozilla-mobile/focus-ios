/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class OnboardingEventsHandler {
    
    static var sharedInstance = OnboardingEventsHandler()
    
    //TODO: Check when old onboarding should be displayed
    private let displayOldOnboarding = false
    
    private var shouldDisplayShieldPopUp: Bool = false
    private var shouldDisplayTrashPopUp: Bool = false
    private var shouldDisplaySettingsPopUp: Bool = false
    private var shouldDisplayTrackingProtectionPopUp: Bool = false
    private var visitedURLcounter = 0
    
    var shouldDisplayOnboarding: Bool {
        UserDefaults.standard.integer(forKey: OnboardingConstants.onboardingVersion) != OnboardingConstants.introVersion
    }
    
    func presentOnboardingScreen(from viewController: UIViewController) {
        let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.onboardingVersion)
        if prefIntroDone < OnboardingConstants.introVersion {
            let introViewController = IntroViewController()
            introViewController.modalPresentationStyle = .fullScreen
            let newOnboardingViewController = NewOnboardingReplaceViewController()
            newOnboardingViewController.modalPresentationStyle = .formSheet
            viewController.present(displayOldOnboarding ? introViewController : newOnboardingViewController, animated: true, completion: nil)
        }
    }
    
    func onboardingDidDismiss() {
        UserDefaults.standard.set(OnboardingConstants.introVersion, forKey: OnboardingConstants.onboardingVersion)
        UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.whatsNewVersion)
        shouldDisplayShieldPopUp = true
        shouldDisplayTrashPopUp = true
        shouldDisplaySettingsPopUp = true
        shouldDisplayTrackingProtectionPopUp = true
    }
    
    func showShieldToolTip(from viewController: UIViewController) {
        guard shouldDisplayShieldPopUp else { return }
        presentTemporaryAlert(from: viewController, message: "Showed shield pop up")
        shouldDisplayShieldPopUp = false
    }

    func showTrashToolTip(from viewController: UIViewController) {
        
        guard shouldDisplayTrashPopUp && visitedURLcounter == 3 else { return }
        presentTemporaryAlert(from: viewController, message: "Showed trash pop up")
        shouldDisplayTrashPopUp = false
    }
    
    func showSettingsToolTip(from viewController: UIViewController) {
        //TODO: Check after how many visited URLs should be displayed
        guard shouldDisplaySettingsPopUp && visitedURLcounter >= 5 else { return }
        presentTemporaryAlert(from: viewController, message: "Showed settings pop up")
        shouldDisplaySettingsPopUp = false
    }
    
    func showTrackingProtectionToolTip(from viewController: UIViewController) {
        //TODO: Check how the UI should be displayed depending on which of the two versions of TrackingProtectionVC is displayed
        guard shouldDisplayTrackingProtectionPopUp else { return }
        presentTemporaryAlert(from: viewController, message: "Showed tracking protection pop up")
        shouldDisplayTrackingProtectionPopUp = false
    }
    
    func incrementCounter() {
        visitedURLcounter += 1
    }
    
    //TODO: Replace with tooltip UI
    private func presentTemporaryAlert(from vc: UIViewController, message: String) {
        let alert = UIAlertController(title: "Test Alert", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        vc.present(alert, animated: true, completion: nil)
    }

}
