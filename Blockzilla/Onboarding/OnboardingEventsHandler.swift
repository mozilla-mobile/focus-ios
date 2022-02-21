/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Combine

class OnboardingEventsHandler {
    
    enum Action {
        case applicationDidLaunch
        case onboardingDidDismiss
        case startBrowsing
        case resetBrowser
        case showTrackingProtection
    }
    
    @Published var shouldPresentOnboarding: Bool = false
    @Published var shouldPresentShieldToolTip: Bool = false
    @Published var shouldPresentTrashToolTip: Bool = false
    @Published var shouldPresentMenuToolTip: Bool = false
    @Published var shouldPresentTrackingProtectionToolTip: Bool = false
    
    private var visitedURLcounter = 0
    private var menuToolTipDidAppear = false
    private var trackingProtectionToolTipDidAppear = false
    
    func send(_ action: OnboardingEventsHandler.Action) {
        switch action {
        case .applicationDidLaunch:
            let prefIntroDone = UserDefaults.standard.integer(forKey: OnboardingConstants.onboardingVersion)
            shouldPresentOnboarding = prefIntroDone < OnboardingConstants.introVersion
            
        case .onboardingDidDismiss:
            UserDefaults.standard.set(OnboardingConstants.introVersion, forKey: OnboardingConstants.onboardingVersion)
            UserDefaults.standard.set(AppInfo.shortVersion, forKey: OnboardingConstants.whatsNewVersion)
            
        case .startBrowsing:
            visitedURLcounter += 1
            shouldPresentShieldToolTip = shouldPresentOnboarding && visitedURLcounter == 1
            shouldPresentTrashToolTip = shouldPresentOnboarding && visitedURLcounter == 3
            
        case .resetBrowser:
            //TODO: Check after how many visited URLs should be displayed
            shouldPresentMenuToolTip = shouldPresentOnboarding && (visitedURLcounter >= 5 && !menuToolTipDidAppear)
            if shouldPresentMenuToolTip {
                menuToolTipDidAppear = true
            }
            
        case .showTrackingProtection:
            //TODO: Check how the UI should be displayed depending on which of the two versions of TrackingProtectionVC is displayed
            shouldPresentTrackingProtectionToolTip = shouldPresentOnboarding && !trackingProtectionToolTipDidAppear
            trackingProtectionToolTipDidAppear = true
        }
    }
    
}
