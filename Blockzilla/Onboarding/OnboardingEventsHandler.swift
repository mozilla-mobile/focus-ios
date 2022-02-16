/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class OnboardingEventsHandler {
    
    static var sharedInstance = OnboardingEventsHandler()
    
    //TODO: Check when old onboarding should be displayed
    private let displayOldOnboarding = false
    
    func presentOnboardingScreen(from viewController: UIViewController) {
        let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDone)
        if prefIntroDone < OnboardingConstants.prefIntroVersion {
            let introViewController = IntroViewController()
            introViewController.modalPresentationStyle = .fullScreen
            let newOnboardingViewController = NewOnboardingReplaceViewController()
            newOnboardingViewController.modalPresentationStyle = .formSheet
            viewController.present(displayOldOnboarding ? introViewController : newOnboardingViewController, animated: true, completion: nil)
        }
    }
    
    func onboardingDidDismiss() {
        UserDefaults.standard.set(OnboardingConstants.prefIntroVersion, forKey: OnboardingConstants.prefIntroDone)
        UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDone)
        shouldDisplayFirstPopUp = true
        shouldShowTrashPopUp = true
        shouldShowSettingsPopUp = true
        shouldShowTrackingProtectionPopUp = true
    }
    
    var shouldDisplayOnboarding: Bool {
        UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDone) != OnboardingConstants.prefIntroVersion
    }
    func incrementCounter() {
        visitedURLcounter += 1
    }
    func showtrashpopup(from viewController: UIViewController) {
        
        guard shouldShowTrashPopUp && visitedURLcounter == 3 else { return }
        presentTemporaryAlert(from: viewController, message: "showed Trashpop up")
        shouldShowTrashPopUp = false
    }
    
    func showSettingspopup(from viewController: UIViewController) {
        
        guard shouldShowSettingsPopUp && visitedURLcounter >= 5 else { return }
        presentTemporaryAlert(from: viewController, message: "showed settings pop up")
        shouldShowSettingsPopUp = false
    }
    
    func showTrackingProtectionspopup(from viewController: UIViewController) {
        
        guard shouldShowTrackingProtectionPopUp else { return }
        presentTemporaryAlert(from: viewController, message: "showed trackingprotection pop up")
        shouldShowTrackingProtectionPopUp = false
    }
    func showFirstPopUp(from viewController: UIViewController) {
        guard shouldDisplayFirstPopUp else { return }
        presentTemporaryAlert(from: viewController, message: "showed first pop up")
        shouldDisplayFirstPopUp = false
    }
    var shouldDisplayFirstPopUp: Bool = false
    var shouldShowTrashPopUp: Bool = false
    var shouldShowSettingsPopUp: Bool = false
    var shouldShowTrackingProtectionPopUp: Bool = false
    var visitedURLcounter = 0
    
    
    func presentTemporaryAlert(from vc: UIViewController, message: String) {
        let alert = UIAlertController(title: "Test Alert", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        vc.present(alert, animated: true, completion: nil)
    }

}
