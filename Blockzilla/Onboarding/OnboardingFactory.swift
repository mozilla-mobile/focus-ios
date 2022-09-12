/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Onboarding
import SwiftUI

class OnboardingFactory {
    static func makeOnboardingEventsHandler(_ shouldShowNewOnboarding: () -> Bool) -> OnboardingEventsHandling {
        let getShownTips: () -> Set<ToolTipRoute> = {
            return UserDefaults
                .standard
                .data(forKey: OnboardingConstants.shownTips)
                .flatMap {
                    try? JSONDecoder().decode(Set<ToolTipRoute>.self, from: $0)
                } ?? []
        }

        let setShownTips: (Set<ToolTipRoute>) -> Void = { tips in
            let data = try? JSONEncoder().encode(tips)
            UserDefaults.standard.set(data, forKey: OnboardingConstants.shownTips)
        }

        let alwaysShowOnboarding: () -> Bool = {
            UserDefaults.standard.bool(forKey: OnboardingConstants.alwaysShowOnboarding)
        }

        if shouldShowNewOnboarding() {
            return OnboardingEventsHandlerV2(
                alwaysShowOnboarding: alwaysShowOnboarding,
                getShownTips: getShownTips,
                setShownTips: setShownTips
            )
        } else {
            return OnboardingEventsHandlerV1(
                alwaysShowOnboarding: alwaysShowOnboarding,
                getShownTips: getShownTips,
                setShownTips: setShownTips
            )
        }
    }

    static func make(onboardingType: OnboardingVersion, dismissAction: @escaping () -> Void) -> (onboardingViewController: UIViewController, animated: Bool) {
        switch onboardingType {
        case .v2:
            let controller = UIHostingController(rootView: FirstOnboardingView(
                config: .init(title: .onboardingTitle, subtitle: .onboardingSubtitleV2, buttonTitle: .onboardingButtonTitleV2),
                defaultBrowserConfig: DefaultBrowserViewConfig(title: UIConstants.strings.defaultBrowserOnboardingViewTitleV2, firstSubtitle: UIConstants.strings.defaultBrowserOnboardingViewFirstSubtitleV2, secondSubtitle: UIConstants.strings.defaultBrowserOnboardingViewSecondSubtitleV2, topButtonTitle: UIConstants.strings.defaultBrowserOnboardingViewTopButtonTitleV2, bottomButtonTitle: UIConstants.strings.defaultBrowserOnboardingViewBottomButtonTitleV2), dismissAction: dismissAction))

            controller.modalPresentationStyle = .formSheet
            controller.isModalInPresentation = true
            return (controller, true)

        case .v1:
            let controller = OnboardingViewController(
                config: .init(
                    onboardingTitle: .onboardingTitle,
                    onboardingSubtitle: .onboardingSubtitle,
                    instructions: [
                        .init(title: .onboardingIncognitoTitle, subtitle: .onboardingIncognitoDescription, image: .privateMode),
                        .init(title: .onboardingHistoryTitle, subtitle: .onboardingHistoryDescription, image: .history),
                        .init(title: .onboardingProtectionTitle, subtitle: .onboardingProtectionDescription, image: .settings)
                    ],
                    onboardingButtonTitle: .onboardingButtonTitle
                ),
                dismissOnboardingScreen: dismissAction
            )
            controller.modalPresentationStyle = .formSheet
            controller.isModalInPresentation = true
            return (controller, true)

        }
    }
}

fileprivate extension String {
    static let onboardingTitle = String(format: .onboardingTitleFormat, AppInfo.config.productName)
    static let onboardingTitleFormat = NSLocalizedString("Onboarding.Title", value: "Welcome to Firefox %@!", comment: "Text for a label that indicates the title for onboarding screen. Placeholder can be (Focus or Klar).")
    static let onboardingSubtitle = NSLocalizedString("Onboarding.Subtitle", value: "Take your private browsing to the next level.", comment: "Text for a label that indicates the subtitle for onboarding screen.")
    static let onboardingSubtitleV2 = NSLocalizedString("NewOnboarding.Subtitle.V2", value: "Fast. Private. No Distractions.", comment: "Text for a label that indicates the subtitle for the onboarding screen version 2.")
    static let onboardingIncognitoTitle = NSLocalizedString("Onboarding.Incognito.Title", value: "More than just incognito", comment: "Text for a label that indicates the title of incognito section from onboarding screen.")
    static let onboardingIncognitoDescription = String(format: NSLocalizedString("Onboarding.Incognito.Description", value: "%@ is a dedicated privacy browser with tracking protection and content blocking.", comment: "Text for a label that indicates the description of incognito section from onboarding screen. Placeholder can be (Focus or Klar)."), AppInfo.productName)
    static let onboardingHistoryTitle = NSLocalizedString("Onboarding.History.Title", value: "Your history doesn’t follow you", comment: "Text for a label that indicates the title of history section from onboarding screen.")
    static let onboardingHistoryDescription = NSLocalizedString("Onboarding.History.Description", value: "Erase your browsing history, passwords, cookies, and prevent unwanted ads from following you in a simple click!", comment: "Text for a label that indicates the description of history section from onboarding screen.")
    static let onboardingProtectionTitle = NSLocalizedString("Onboarding.Protection.Title", value: "Protection at your own discretion", comment: "Text for a label that indicates the title of protection section from onboarding screen.")
    static let onboardingProtectionDescription = NSLocalizedString("Onboarding.Protection.Description", value: "Configure settings so you can decide how much or how little you share.", comment: "Text for a label that indicates the description of protection section from onboarding screen.")
    static let onboardingButtonTitle = NSLocalizedString("Onboarding.Button.Title", value: "Start browsing", comment: "Text for a label that indicates the title of button from onboarding screen")
    static let onboardingButtonTitleV2 = NSLocalizedString("NewOnboarding.Button.Title.V2", value: "Get Started", comment: "Text for a label that indicates the title of button from onboarding screen version 2.")

}
