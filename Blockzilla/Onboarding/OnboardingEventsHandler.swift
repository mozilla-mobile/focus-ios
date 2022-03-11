/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Combine

class OnboardingEventsHandler {
    
    private let nimbus = NimbusWrapper.shared
    
    public var shouldShowNewOnboarding: Bool {
    #if DEBUG
        guard UserDefaults.standard.bool(forKey: "IgnoreOnboardingExperiment") else {
            return nimbus.shouldShowNewOnboarding
        }
        return UserDefaults.standard.bool(forKey: "ShowNewOnboarding")
    #else
        return nimbus.shouldShowNewOnboarding
    #endif
    }
    
    enum Action {
        case applicationDidLaunch
        case enterHome
        case startBrowsing
        case showTrackingProtection
    }
    
    enum OnboardingType: Equatable, Hashable {
        init(_ shouldShowNewOnboarding: Bool) {
            self = shouldShowNewOnboarding ? .new : .old
        }
        case new
        case old
    }
    
    enum ToolTipRoute: Equatable, Hashable {
        case onboarding(OnboardingType)
        case trackingProtection
        case trackingProtectionShield
        case trash
        case menu
    }
    
    @Published var route: ToolTipRoute?
    
    private var visitedURLcounter = 0
    private var shownTips = Set<ToolTipRoute>()
    
    func send(_ action: OnboardingEventsHandler.Action) {
        switch action {
        case .applicationDidLaunch:
            let type = OnboardingType(shouldShowNewOnboarding)
            let onboardingRoute = ToolTipRoute.onboarding(type)
            if UserDefaults.standard.bool(forKey: OnboardingConstants.onboardingDidAppear) {
                shownTips.insert(onboardingRoute)
            }
        #if DEBUG
            if UserDefaults.standard.bool(forKey: "AlwaysShowOnboarding") {
                shownTips.remove(onboardingRoute)
            }
        #endif
            show(route: onboardingRoute)
            
        case .enterHome:
            guard shouldShowNewOnboarding else { return }
            show(route: .menu)
            
        case .startBrowsing:
            visitedURLcounter += 1
            guard shouldShowNewOnboarding else { return }
            
            if visitedURLcounter == 1 {
                show(route: .trackingProtectionShield)
            }
            
            if visitedURLcounter == 3 {
                show(route: .trash)
            }
            
        case .showTrackingProtection:
            guard shouldShowNewOnboarding else { return }
            show(route: .trackingProtection)
        }
    }
    
    private func show(route: ToolTipRoute) {
        if !shownTips.contains(route) {
            self.route = route
            shownTips.insert(route)
        }
    }
}
