/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI

struct InternalExperimentsSettingsView: View {
    @State private var enablePreviewCollections = false
    var body: some View {
        NavigationView {
            Form {
                SwiftUI.Section {
                    Toggle(isOn: $enablePreviewCollections) {
                        VStack(alignment: .leading) {
                            Text("Use Preview Collection")
                            Text("Requires restart").font(.caption)
                        }
                    }
                }
            }.navigationBarTitle("Experiment Settings")
        }
    }
}

struct InternalExperimentsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InternalExperimentsSettingsView()
    }
}
