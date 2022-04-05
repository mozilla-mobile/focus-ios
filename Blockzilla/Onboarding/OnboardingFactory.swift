/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Onboarding

class OnboardingFactory {
    static func make(onboardingType :OnboardingEventsHandler.OnboardingType, dismissAction: @escaping () -> Void) -> (onboardingViewController: UIViewController, animated: Bool) {
        switch onboardingType {
        case .new:
            let newOnboardingViewController = OnboardingViewController(
                config: .init(
                    welcomeText: .welcomeText,
                    onboardingTitle: .onboardingTitle,
                    onboardingSubtitle: .onboardingSubtitle,
                    onboardingIncognitoTitle: .onboardingIncognitoTitle,
                    onboardingIncognitoDescription: .onboardingIncognitoDescription,
                    onboardingHistoryTitle: .onboardingHistoryTitle,
                    onboardingHistoryDescription: .onboardingHistoryDescription,
                    onboardingProtectionTitle: .onboardingProtectionTitle,
                    onboardingProtectionDescription: .onboardingProtectionDescription,
                    onboardingButtonTitle: .onboardingButtonTitle
                ),
                dismissOnboardingScreen: dismissAction
            )
            newOnboardingViewController.modalPresentationStyle = .formSheet
            newOnboardingViewController.isModalInPresentation = true
            return (newOnboardingViewController, true)
            
        case .old:
            let introViewController = IntroViewController()
            introViewController.modalPresentationStyle = .fullScreen
            introViewController.dismissOnboardingScreen = dismissAction
            return (introViewController, false)
        }
    }
}

fileprivate extension String {
    static let welcomeText = String(format: .onboardingTitle, AppInfo.config.productName)
    static let onboardingTitle = NSLocalizedString("Onboarding.Title", value: "Welcome to Firefox %@!", comment: "Text for a label that indicates the title for onboarding screen. (Focus and Klar)")
    static let onboardingSubtitle = NSLocalizedString("Onboarding.Subtitle", value: "Take your private browsing to the next level.", comment: "Text for a label that indicates the subtitle for onboarding screen.")
    static let onboardingIncognitoTitle = NSLocalizedString("Onboarding.Incognito.Title", value: "More than just incognito", comment: "Text for a label that indicates the title of incognito section from onboarding screen.")
    static let onboardingIncognitoDescription = NSLocalizedString("Onboarding.Incognito.Description", value: "Focus is a dedicated privacy browser with tracking protection and content blocking.", comment: "Text for a label that indicates the description of incognito section from onboarding screen.")
    static let onboardingHistoryTitle = NSLocalizedString("Onboarding.History.Title", value: "Your history doesn’t follow you", comment: "Text for a label that indicates the title of history section from onboarding screen.")
    static let onboardingHistoryDescription = NSLocalizedString("Onboarding.History.Description", value: "Erase your browsing history, passwords, bookmarks, cookies, and prevent unwanted ads from following you in a simple click!", comment: "Text for a label that indicates the description of history section from onboarding screen.")
    static let onboardingProtectionTitle = NSLocalizedString("Onboarding.Protection.Title", value: "Protection at your own discretion", comment: "Text for a label that indicates the title of protection section from onboarding screen.")
    static let onboardingProtectionDescription = NSLocalizedString("Onboarding.Protection.Description", value: "Configure settings so you can decide how much or how little you share.", comment: "Text for a label that indicates the description of protection section from onboarding screen.")
    static let onboardingButtonTitle = NSLocalizedString("Onboarding.Button.Title", value: "Start browsing", comment: "Text for a label that indicates the title of button from onboarding screen")
}
