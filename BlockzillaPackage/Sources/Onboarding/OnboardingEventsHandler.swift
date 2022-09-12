/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Combine

public enum Action {
    case applicationDidLaunch
    case enterHome
    case showTrackingProtection
    case trackerBlocked
    case showTrash
    case clearTapped
    case startBrowsing
}

public enum ToolTipRoute: Equatable, Hashable, Codable {
    case onboarding(OnboardingVersion)
    case trackingProtection
    case trackingProtectionShield
    case trackingProtectionShieldV2
    case trash
    case trashV2
    case searchBar
    case widget
    case menu
}

public enum OnboardingVersion: Equatable, Hashable, Codable {
    init(_ shouldShowNewOnboarding: Bool) {
        self = shouldShowNewOnboarding ? .v2 : .v1
    }
    case v2
    case v1
}

public protocol OnboardingEventsHandling: AnyObject {
    var route: ToolTipRoute? { get set }
    var routePublisher: Published<ToolTipRoute?>.Publisher { get }
    func send(_ action: Action)
}

public class OnboardingEventsHandlerV2: OnboardingEventsHandling {

    private let alwaysShowOnboarding: () -> Bool
    private let setShownTips: (Set<ToolTipRoute>) -> Void

    @Published public var route: ToolTipRoute?
    public var routePublisher: Published<ToolTipRoute?>.Publisher { $route }

    private var visitedURLcounter = 0
    private var shownTips = Set<ToolTipRoute>() {
        didSet {
            setShownTips(shownTips)
        }
    }

    public init(
        alwaysShowOnboarding: @escaping () -> Bool,
        visitedURLcounter: Int = 0,
        getShownTips: () -> Set<ToolTipRoute>,
        setShownTips: @escaping (Set<ToolTipRoute>) -> Void
    ) {
        self.alwaysShowOnboarding = alwaysShowOnboarding
        self.visitedURLcounter = visitedURLcounter
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

public class OnboardingEventsHandlerV1: OnboardingEventsHandling {

    private let alwaysShowOnboarding: () -> Bool
    private let setShownTips: (Set<ToolTipRoute>) -> Void

    @Published public var route: ToolTipRoute?
    public var routePublisher: Published<ToolTipRoute?>.Publisher { $route }

    private var visitedURLcounter = 0
    private var shownTips = Set<ToolTipRoute>() {
        didSet {
            setShownTips(shownTips)
        }
    }

    public init(
        alwaysShowOnboarding: @escaping () -> Bool,
        visitedURLcounter: Int = 0,
        getShownTips: () -> Set<ToolTipRoute>,
        setShownTips: @escaping (Set<ToolTipRoute>) -> Void
    ) {
        self.alwaysShowOnboarding = alwaysShowOnboarding
        self.visitedURLcounter = visitedURLcounter
        self.setShownTips = setShownTips
        self.shownTips = getShownTips()
    }

    public func send(_ action: Action) {
        switch action {
        case .applicationDidLaunch:
            show(route: .onboarding(.v1))

        case .enterHome:
            show(route: .menu)

        case .startBrowsing:
            visitedURLcounter += 1

            if visitedURLcounter == 3 {
                show(route: .trash)
            }

        case .showTrackingProtection:
            show(route: .trackingProtection)

        case .trackerBlocked:
            show(route: .trackingProtectionShield)

        case .showTrash:
            break

        case .clearTapped:
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
