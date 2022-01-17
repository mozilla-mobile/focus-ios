/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI
import Glean

struct InternalTelemetrySettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                SwiftUI.Section {
                    Text("Telemetry Identifier")
                    Text("A974A227-B8F1-48E7-9547-759AB68AC4D3") // TODO
                        .font(.caption)
                }

                SwiftUI.Section {
                    Button("Enable Testing Mode") {
                        Glean.shared.enableTestingMode()
                    }
                }
            }.navigationBarTitle("Telemetry Settings")
        }
    }
}

struct InternalTelemetrySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InternalTelemetrySettingsView()
    }
}
