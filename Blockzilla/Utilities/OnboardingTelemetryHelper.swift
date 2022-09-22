// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Glean

class OnboardingTelemetryHelper {
    static func onboardingFirstScreenDisplayed() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.open, object: TelemetryEventObject.onboardingFirstScreen)
        print("------------ Onboarding First Screen Displayed ------------")
    }

    static func onboardingFirstScreenGetStartedClicked() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.onboardingFirstScreenGetStarted)
        print("------------ Onboarding First Get Started Clicked ------------")
    }

    static func onboardingFirstScreenDismiss() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.close, object: TelemetryEventObject.onboardingFirstScreen)
        print("------------ Onboarding First Screen Dismissed ------------")
    }

    static func onboardingSecondScreenDisplayed() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.open, object: TelemetryEventObject.onboardingSecondScreen)
        print("------------ Onboarding Second Screen Displayed ------------")
    }

    static func onboardingSecondScreenSetToDefaultClicked() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.onboardingSecondScreenSetToDefault)
        print("------------ Onboarding Second Screen Set to Default Clicked ------------")
    }

    static func onboardingSecondScreenSkipClicked() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.onboardingSecondScreenSkipped)
        print("------------ Onboarding Second Screen Skipped Clicked ------------")
    }

    static func onboardingSecondScreenDismiss() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.close, object: TelemetryEventObject.onboardingSecondScreen)
        print("------------ Onboarding Second Screen Dismissed ------------")
    }

    static func onboardingWidgetScreenDisplayed() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.open, object: TelemetryEventObject.onboardingWidgetTooltip)
        print("------------ Onboarding Widget Card Displayed ------------")
    }

    static func onboardingWidgetPrimaryActionClicked() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.onboardingWidgetTooltip)
        print("------------ Onboarding Widget Primary Clicked ------------")
    }

    static func onboardingWidgetScreenDismiss() {
//        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.close, object: TelemetryEventObject.onboardingWidgetTooltip)
        print("------------ Onboarding Widget Card Dismissed ------------")
    }
}
