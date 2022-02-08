/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit


public extension UIColor {
    static let locationBar = UIColor(named: "LocationBar", in: .module, compatibleWith: nil)!
    static let primaryText = UIColor(named: "PrimaryText", in: .module, compatibleWith: nil)!
    static let accent = UIColor(named: "Accent", in: .module, compatibleWith: nil)!
    static let secondaryText = UIColor(named: "SecondaryText", in: .module, compatibleWith: nil)!
    //    static let above = UIColor(named: "Above")!
    //
    //    static let defaultFont = UIColor(named: "DefaultFont")!
    //    static let firstRunTitle = UIColor(named: "FirstRunTitle")!
    static let foundation = UIColor(named: "Foundation", in: .module, compatibleWith: nil)!
    //    static let gradientBackground = UIColor(named: "GradientBackground")!
        static let gradientFirst = UIColor(named: "GradientFirst", in: .module, compatibleWith: nil)!
        static let gradientSecond = UIColor(named: "GradientSecond", in: .module, compatibleWith: nil)!
        static let gradientThird = UIColor(named: "GradientThird", in: .module, compatibleWith: nil)!
    //    static let grey10 = UIColor(named: "Grey10")!
    //    static let grey30 = UIColor(named: "Grey30")!
    //    static let grey50 = UIColor(named: "Grey50")!
    //    static let grey70 = UIColor(named: "Grey70")!
    //    static let grey90 = UIColor(named: "Grey90")!
    //    static let ink90 = UIColor(named: "Ink90")!
    //    static let inputPlaceholder = UIColor(named: "InputPlaceholder")!
    //    static let launchScreenBackground = UIColor(named: "LaunchScreenBackground")!
    //
    //    static let magenta40 = UIColor(named: "Magenta40")!
    //    static let magenta70 = UIColor(named: "Magenta70")!
    //    static let primaryDark = UIColor(named: "PrimaryDark")!
    //
    //    static let purple50 = UIColor(named: "Purple50")!
    //    static let purple80 = UIColor(named: "Purple80")!
    //    static let red60 = UIColor(named: "Red60")!
    //    static let scrim = UIColor(named: "Scrim")!
    //    static let searchGradientFirst = UIColor(named: "SearchGradientFirst")!
    //    static let searchGradientSecond = UIColor(named: "SearchGradientSecond")!
    //    static let searchGradientThird = UIColor(named: "SearchGradientThird")!
    //    static let searchGradientFourth = UIColor(named: "SearchGradientFourth")!
    //    static let secondaryText = UIColor(named: "SecondaryText")!
    //    static let secondaryButton = UIColor(named: "SecondaryButton")!
    
    /**
     * Initializes and returns a color object for the given RGB hex integer.
     */
    convenience init(rgb: Int, alpha: Float = 1) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8)  / 255.0,
            blue: CGFloat((rgb & 0x0000FF) >> 0)  / 255.0,
            alpha: CGFloat(alpha))
    }
}
