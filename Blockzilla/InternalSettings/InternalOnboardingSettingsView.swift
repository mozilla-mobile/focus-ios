/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI

struct InternalOnboardingSettingsView {
    @ObservedObject var internalSettings = InternalSettings()
}

extension InternalOnboardingSettingsView: View {
    var body: some View {
        Form {
            Section(footer: Text("To show the old version of onboarding disable first the Nimbus experiment, then turn on the option.")) {
                Toggle(isOn: $internalSettings.ignoreOnboardingExperiment) {
                    Text(verbatim: "Ignore Onboarding Experiment")
                }
                Toggle(isOn: $internalSettings.alwaysShowOnboarding) {
                    Text(verbatim: "Always Show Onboarding + Tips")
                }
                Toggle(isOn: $internalSettings.showOldOnboarding) {
                    Text(verbatim: "Show Old Onboarding")
                }
            }

            Section {
                Button("Clear cached shown tips") {
                    UserDefaults.standard.removeObject(forKey: OnboardingConstants.shownTips)
                    Toast(text: "Cache cleared").show()
                }
            }
        }.navigationBarTitle(Text(verbatim: "Onboarding Settings"))
    }
}

struct InternalOnboardingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InternalOnboardingSettingsView()
    }
}
