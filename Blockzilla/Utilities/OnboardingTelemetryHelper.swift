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
    public enum Event {
        case getStartedAppeared
        case getStartedCloseTapped
        case getStartedButtonTapped
        case defaultBrowserCloseTapped
        case defaultBrowserSettingsTapped
        case defaultBrowserSkip
        case defaultBrowserAppeared
        case widgetCardAppeared
        case widgetPrimaryButtonTapped
        case widgetCloseTapped
    }

    func handle(event: Event) {
        switch event {
        case .getStartedAppeared:
            onboardingGetStartedScreenDisplayed()
        case .getStartedCloseTapped:
            onboardingGetStartedScreenDismiss()
        case .getStartedButtonTapped:
            onboardingGetStartedScreenButtonTapped()
        case .defaultBrowserCloseTapped:
            onboardingDefaultBrowserScreenDismiss()
        case .defaultBrowserSettingsTapped:
            onboardingDefaultBrowserScreenButtonTapped()
        case .defaultBrowserSkip:
            onboardingDefaultBrowserScreenSkipTapped()
        case .defaultBrowserAppeared:
            onboardingDefaultBrowserScreenDisplayed()
        case .widgetCardAppeared:
            onboardingWidgetScreenDisplayed()
        case .widgetPrimaryButtonTapped:
            onboardingWidgetPrimaryActionClicked()
        case .widgetCloseTapped:
            onboardingWidgetScreenDismiss()
        }
    }

    func onboardingGetStartedScreenButtonTapped() {
        let cardTypeExtra = GleanMetrics.Onboarding.PrimaryButtonTapExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.primaryButtonTap.record(cardTypeExtra)
    }

    func onboardingDefaultBrowserScreenDismiss() {
        let cardTypeExtra = GleanMetrics.Onboarding.CloseTapExtra(cardType: CardViewType.defaultBrowserView.rawValue)
        GleanMetrics.Onboarding.closeTap.record(cardTypeExtra)
    }

    func onboardingDefaultBrowserScreenButtonTapped() {
        GleanMetrics.DefaultBrowserOnboarding.goToSettingsPressed.add()
    }

    func onboardingDefaultBrowserScreenSkipTapped() {
        GleanMetrics.DefaultBrowserOnboarding.skipButtonTapped.record()
    }

    func onboardingDefaultBrowserScreenDisplayed() {
        let cardTypeExtra = GleanMetrics.Onboarding.CardViewExtra(cardType: CardViewType.defaultBrowserView.rawValue)
        GleanMetrics.Onboarding.cardView.record(cardTypeExtra)
    }

    func onboardingGetStartedScreenDisplayed() {
        let cardTypeExtra = GleanMetrics.Onboarding.CardViewExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.cardView.record(cardTypeExtra)
    }

    func onboardingGetStartedScreenDismiss() {
        let cardTypeExtra = GleanMetrics.Onboarding.CloseTapExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.closeTap.record(cardTypeExtra)
    }

    func onboardingWidgetScreenDisplayed() {
        let cardTypeExtra = GleanMetrics.Onboarding.CardViewExtra(cardType: CardViewType.widgetTutorial.rawValue)
        GleanMetrics.Onboarding.cardView.record(cardTypeExtra)
    }

    func onboardingWidgetPrimaryActionClicked() {
        let cardTypeExtra = GleanMetrics.Onboarding.PrimaryButtonTapExtra(cardType: CardViewType.welcomeView.rawValue)
        GleanMetrics.Onboarding.primaryButtonTap.record(cardTypeExtra)
    }

    func onboardingWidgetScreenDismiss() {
        let cardTypeExtra = GleanMetrics.Onboarding.CloseTapExtra(cardType: CardViewType.widgetTutorial.rawValue)
        GleanMetrics.Onboarding.closeTap.record(cardTypeExtra)
    }
}
