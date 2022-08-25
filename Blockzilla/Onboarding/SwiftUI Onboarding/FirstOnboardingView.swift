// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct FirstOnboardingView: View {
    private let dismissAction: (() -> Void)?

    init(dismissAction: (() -> Void)?) {
        self.dismissAction = dismissAction
    }

    var body: some View {
        Button(action: {
            dismissAction?()
        }, label: {
            Text("Dismiss")
        })
        Text("First Onboarding View")
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FirstOnboardingView(dismissAction: nil)
    }
}
