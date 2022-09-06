// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

public extension Image {
    static let logo = Image("icon_logo", bundle: Bundle.module)
    static let close = Image("icon_close", bundle: Bundle.module)
    static let background = Image("icon_background", bundle: Bundle.module)
    static let huggingFocus = Image("icon_hugging_focus", bundle: .module)
    static let magnifyingGlass = Image(systemName: "magnifyingglass")
}

extension Gradient {
    static let quickAccessWidget = Gradient(colors: [Color("GradientFirst", bundle: .module), Color("GradientSecond", bundle: .module)])
}
