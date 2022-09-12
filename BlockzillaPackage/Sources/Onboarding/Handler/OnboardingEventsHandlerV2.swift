// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

public class OnboardingEventsHandlerV2: OnboardingEventsHandling {

    private let alwaysShowOnboarding: () -> Bool
    private let setShownTips: (Set<ToolTipRoute>) -> Void

    @Published public var route: ToolTipRoute?
    public var routePublisher: Published<ToolTipRoute?>.Publisher { $route }

    private var shownTips = Set<ToolTipRoute>() {
        didSet {
            setShownTips(shownTips)
        }
    }

    public init(
        alwaysShowOnboarding: @escaping () -> Bool,
        getShownTips: () -> Set<ToolTipRoute>,
        setShownTips: @escaping (Set<ToolTipRoute>) -> Void
    ) {
        self.alwaysShowOnboarding = alwaysShowOnboarding
        self.setShownTips = setShownTips
        self.shownTips = getShownTips()
    }

    public func send(_ action: Action) {
        switch action {
        case .applicationDidLaunch:
            show(route: .onboarding(.v2))

        case .enterHome:
            show(route: .searchBar)

        case .showTrackingProtection:
            show(route: .trackingProtection)

        case .trackerBlocked:
            show(route: .trackingProtectionShieldV2)

        case .showTrash:
            show(route: .trashV2)

        case .clearTapped:
            show(route: .widget)

        case .startBrowsing:
            break
        }
    }

    private func show(route: ToolTipRoute) {
        #if DEBUG
        if alwaysShowOnboarding() {
            shownTips.remove(route)
        }
        #endif

        if !shownTips.contains(route) {
            self.route = route
            shownTips.insert(route)
        }
    }
}
