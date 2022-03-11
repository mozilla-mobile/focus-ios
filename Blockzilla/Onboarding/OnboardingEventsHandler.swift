/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Combine

class OnboardingEventsHandler {
    
    private let alwaysShowOnboarding: () -> Bool
    private let onboardingDidAppear: () -> Bool
    public let shouldShowNewOnboarding: () -> Bool
    
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
    
    internal init(
        alwaysShowOnboarding: @escaping () -> Bool,
        shouldShowNewOnboarding: @escaping () -> Bool,
        onboardingDidAppear: @escaping () -> Bool,
        visitedURLcounter: Int = 0,
        shownTips: Set<OnboardingEventsHandler.ToolTipRoute> = Set<ToolTipRoute>()) {
            self.alwaysShowOnboarding = alwaysShowOnboarding
            self.shouldShowNewOnboarding = shouldShowNewOnboarding
            self.onboardingDidAppear = onboardingDidAppear
            self.visitedURLcounter = visitedURLcounter
            self.shownTips = shownTips
        }
    
    func send(_ action: OnboardingEventsHandler.Action) {
        switch action {
        case .applicationDidLaunch:
            let onboardingRoute = ToolTipRoute.onboarding(OnboardingType(shouldShowNewOnboarding()))
            
            if onboardingDidAppear() {
                shownTips.insert(onboardingRoute)
            }
            #if DEBUG
            if alwaysShowOnboarding() {
                shownTips.remove(onboardingRoute)
            }
            #endif
            show(route: onboardingRoute)
            
        case .enterHome:
            guard shouldShowNewOnboarding() else { return }
            show(route: .menu)
            
        case .startBrowsing:
            visitedURLcounter += 1
            guard shouldShowNewOnboarding() else { return }
            
            if visitedURLcounter == 1 {
                show(route: .trackingProtectionShield)
            }
            
            if visitedURLcounter == 3 {
                show(route: .trash)
            }
            
        case .showTrackingProtection:
            guard shouldShowNewOnboarding() else { return }
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
