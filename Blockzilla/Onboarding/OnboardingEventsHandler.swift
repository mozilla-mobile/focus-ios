/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

struct OnboardingEventsHandler {
    
    static let sharedInstance = OnboardingEventsHandler()
    
    func presentOnboardingScreen(from viewController: UIViewController) {
        let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDone)
        if prefIntroDone < OnboardingConstants.prefIntroVersion {
            UserDefaults.standard.set(OnboardingConstants.prefIntroVersion, forKey: OnboardingConstants.prefIntroDone)
            UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDone)
            let introViewController = IntroViewController()
            introViewController.modalPresentationStyle = .fullScreen
            viewController.present(introViewController, animated: true, completion: nil)
        }
    }
    
    var userHasSeenTheIntro: Bool {
        UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDone) == OnboardingConstants.prefIntroVersion
    }
}
