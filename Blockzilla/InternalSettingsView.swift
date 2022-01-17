/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI

struct InternalSettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                NavigationLink("Telemetry") {
                    InternalTelemetrySettingsView()
                }
                NavigationLink("Experiments") {
                    InternalExperimentsSettingsView()
                }
            }.navigationBarTitle("Internal Settings")
        }
    }
}

struct InternalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InternalSettingsView()
    }
}
