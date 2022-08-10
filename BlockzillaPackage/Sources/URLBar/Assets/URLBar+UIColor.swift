/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit

extension UIColor {
    convenience init?(named name: String) {
        self.init(named: name, in: Bundle.module, compatibleWith: nil)
    }
}

extension UIColor {
    static let accent = UIColor(named: "Accent")!
    static let foundation = UIColor(named: "Foundation")!
    static let gradientFirst = UIColor(named: "GradientFirst")!
    static let gradientSecond = UIColor(named: "GradientSecond")!
    static let gradientThird = UIColor(named: "GradientThird")!
    static let locationBar = UIColor(named: "LocationBar")!
    static let primaryText = UIColor(named: "PrimaryText")!
    static let secondaryText = UIColor(named: "SecondaryText")!
    static let secondaryButton = UIColor(named: "SecondaryButton")!
}
