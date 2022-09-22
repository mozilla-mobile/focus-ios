// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension NSNotification.Name {
    public static let onboardingSkipButtonClicked = Notification.Name("OnboardingSkipButtonClicked")
    public static let onboardingSetAsDefaultButtonClicked = Notification.Name("OnboardingSetAsDefaultButtonClicked")
    public static let onboardingDefaultBrowserAppear = Notification.Name("OnboardingDefaultBrowserAppear")
    public static let onboardingGetStartedButtonClicked = Notification.Name("OnboardingGetStartedButtonClicked")
    public static let onboardingSecondScreenDismissed = Notification.Name("OnboardingSecondScreenDismissed")
}
