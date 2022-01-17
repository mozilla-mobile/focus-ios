/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SwiftUI
import Nimbus

struct InternalExperimentDetailView {
    let experiment: AvailableExperiment
    @State private var selectedBranch: String
    
    init(experiment: AvailableExperiment) {
        self.experiment = experiment
        self.selectedBranch = experiment.referenceBranch ?? "" // TODO Can this actually be nil?
    }
}

extension InternalExperimentDetailView: View {
    var body: some View {
        NavigationView {
            Form {
                SwiftUI.Section {
                    Text(experiment.userFacingDescription)
                }
                SwiftUI.Section(header: Text("Available Branches")) {
                    ForEach(experiment.branches, id: \.slug) { branch in
                        HStack {
                            Text(branch.slug)
                            Spacer()
                            Text("\(branch.ratio)")
                        }
                    }
                }
                SwiftUI.Section {
                    Picker(selection: $selectedBranch, label: Text("Active Branch")) {
                        ForEach(experiment.branches, id: \.slug) { branch in
                            Text(branch.slug)
                        }
                    }
                }
            }.navigationBarTitle(experiment.userFacingName)
        }
    }
}

struct InternalExperimentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let experiment = AvailableExperiment(
            slug: "some-slug",
            userFacingName: "Some Experiment",
            userFacingDescription: "Some Experiment Description This is some longer text that is user facing.",
            branches: [ExperimentBranch(slug: "control", ratio: 50), ExperimentBranch(slug: "test", ratio: 50)],
            referenceBranch: "control"
        )
        InternalExperimentDetailView(experiment: experiment)
    }
}
