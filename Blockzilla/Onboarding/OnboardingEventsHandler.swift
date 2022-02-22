/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Combine

class OnboardingEventsHandler {
    
    var shouldShowNewOnboarding: Bool {
    #if DEBUG
        return UserDefaults.standard.bool(forKey: "ShowNewOnboarding")
    #else
        //TODO: Replace with suitable value from A/B Testing
        return true
    #endif
    }
    
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
            var onboardingDidAppear = UserDefaults.standard.bool(forKey: OnboardingConstants.onboardingDidAppear)
        #if DEBUG
            if UserDefaults.standard.bool(forKey: "AlwaysShowOnboarding") {
                onboardingDidAppear = false
            }
        #endif
            shouldPresentOnboarding = !onboardingDidAppear
            
        case .onboardingDidDismiss:
            UserDefaults.standard.set(true, forKey: OnboardingConstants.onboardingDidAppear)
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
