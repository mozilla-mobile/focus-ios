// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

public enum Screen: CaseIterable {
    case getStarted
    case `default`
}

class ScreenController: ObservableObject {
    @Published var activeScreen = Screen.getStarted

    func open(_ screen: Screen) {
        activeScreen = screen
    }
}
