/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation


struct WhatsNewEventsHandler {
    
    static let sharedInstance = WhatsNewEventsHandler()
    
    //TODO: check which should be the logic of implementation
    var shouldShowWhatsNewButton: Bool {
        UserDefaults.standard.integer(forKey: OnboardingConstants.prefWhatsNewCounter) != 0
    }
    
    func didShowWhatsNewButton() {
        UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDone)
        UserDefaults.standard.removeObject(forKey: OnboardingConstants.prefWhatsNewCounter)
    }
    
    func highlightWhatsNewButton() {
        let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.prefIntroDone)
        // Don't highlight whats new on a fresh install (prefIntroDone == 0 on a fresh install)
        if let lastShownWhatsNew = UserDefaults.standard.string(forKey: OnboardingConstants.prefWhatsNewDone)?.first, let currentMajorRelease = AppInfo.shortVersion.first {
            if prefIntroDone != 0 && lastShownWhatsNew != currentMajorRelease {
                
                let counter = UserDefaults.standard.integer(forKey: OnboardingConstants.prefWhatsNewCounter)
                switch counter {
                case 4:
                    // Shown three times, remove counter
                    UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.prefWhatsNewDone)
                    UserDefaults.standard.removeObject(forKey: OnboardingConstants.prefWhatsNewCounter)
                default:
                    // Show highlight
                    UserDefaults.standard.set(counter+1, forKey: OnboardingConstants.prefWhatsNewCounter)
                }
            }
        }
    }
}
