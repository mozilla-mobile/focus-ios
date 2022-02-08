/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

struct OnboardingEventsHandler {
    
    static let sharedInstance = OnboardingEventsHandler()
    
    func presentOnboardingScreen(from viewController: UIViewController) {
        let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDoneApp)
        if prefIntroDone < OnboardingConstants.prefIntroVersionApp {
            UserDefaults.standard.set(OnboardingConstants.prefIntroVersionApp, forKey: OnboardingConstants.prefIntroDoneApp)
            UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDoneApp)
            let introViewController = IntroViewController()
            viewController.present(introViewController, animated: true, completion: nil)
        }
    }
    
    var userHasSeenTheIntro: Bool {
        UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDoneApp) == OnboardingConstants.prefIntroVersionApp
    }
    
}

struct WhatsNewEventsHandler {
    
    static let sharedInstance = WhatsNewEventsHandler()
    
    //TODO: check which should be the logic of implementation
    var shouldShowWhatsNewButton: Bool {
        UserDefaults.standard.integer(forKey: OnboardingConstants.prefWhatsNewCounterApp) != 0
    }
    
    func didShowWhatsNewButton() {
        UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDoneApp)
        UserDefaults.standard.removeObject(forKey: OnboardingConstants.prefWhatsNewCounterApp)
    }
    
    func highlightWhatsNewButton() {
        let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDoneApp)
        // Don't highlight whats new on a fresh install (prefIntroDone == 0 on a fresh install)
        if let lastShownWhatsNew = UserDefaults.standard.string(forKey: OnboardingConstants.prefWhatsNewDoneApp)?.first, let currentMajorRelease = AppInfo.shortVersion.first {
            if prefIntroDone != 0 && lastShownWhatsNew != currentMajorRelease {
                
                let counter = UserDefaults.standard.integer(forKey: OnboardingConstants.prefWhatsNewCounterApp)
                switch counter {
                case 4:
                    // Shown three times, remove counter
                    UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDoneApp)
                    UserDefaults.standard.removeObject(forKey: OnboardingConstants.prefWhatsNewCounterApp)
                default:
                    // Show highlight
                    UserDefaults.standard.set(counter+1, forKey: OnboardingConstants.prefWhatsNewCounterApp)
                }
            }
        }
    }
}

struct OnboardingConstants {
    static let prefIntroDoneApp = "IntroDone"
    static let prefIntroVersionApp = 2
    static let prefWhatsNewDoneApp = "WhatsNewDone"
    static let prefWhatsNewCounterApp = "WhatsNewCounter"
    
}
