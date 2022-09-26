// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Glean

enum CardViewType: String {
    case welcomeView = "welcome"
    case defaultBrowserView = "default-browser"
    case widgetTutorial = "widget-tutorial"
}

class OnboardingTelemetryHelper {
    static func onboardingFirstScreenDisplayed() {
        let cardTypeExtra = GleanMetrics.Onboarding.CardViewExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.cardView.record(cardTypeExtra)
    }

    static func onboardingFirstScreenGetStartedClicked() {
        let cardTypeExtra = GleanMetrics.Onboarding.PrimaryButtonTapExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.primaryButtonTap.record(cardTypeExtra)
    }

    static func onboardingFirstScreenDismiss() {
        let cardTypeExtra = GleanMetrics.Onboarding.CloseTapExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.closeTap.record(cardTypeExtra)
    }

    static func onboardingSecondScreenDisplayed() {
        let cardTypeExtra = GleanMetrics.Onboarding.CardViewExtra(cardType: CardViewType.defaultBrowserView.rawValue)
        GleanMetrics.Onboarding.cardView.record(cardTypeExtra)
    }

    static func onboardingSecondScreenSetToDefaultClicked() {
        GleanMetrics.DefaultBrowserOnboarding.goToSettingsPressed.add()
    }

    static func onboardingSecondScreenSkipClicked() {
        GleanMetrics.DefaultBrowserOnboarding.skipButtonTapped.record()
    }

    static func onboardingSecondScreenDismiss() {
        let cardTypeExtra = GleanMetrics.Onboarding.CloseTapExtra(cardType: CardViewType.defaultBrowserView.rawValue)
        GleanMetrics.Onboarding.closeTap.record(cardTypeExtra)
    }

    static func onboardingWidgetScreenDisplayed() {
        let cardTypeExtra = GleanMetrics.Onboarding.CardViewExtra(cardType: CardViewType.widgetTutorial.rawValue)
        GleanMetrics.Onboarding.cardView.record(cardTypeExtra)
    }

    static func onboardingWidgetPrimaryActionClicked() {
        let cardTypeExtra = GleanMetrics.Onboarding.PrimaryButtonTapExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.primaryButtonTap.record(cardTypeExtra)
    }

    static func onboardingWidgetScreenDismiss() {
        let cardTypeExtra = GleanMetrics.Onboarding.CloseTapExtra(cardType: CardViewType.widgetTutorial.rawValue)
        GleanMetrics.Onboarding.closeTap.record(cardTypeExtra)
    }
}
