
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

public extension UIImage {
    static let trackingProtectionOff = UIImage(named: "tracking_protection_off", in: .module, with: nil)!
    static let trackingProtectionOn = UIImage(named: "tracking_protection", in: .module, with: nil)!
    static let connectionNotSecure = UIImage(named: "connection_not_secure", in: .module, with: nil)!
    static let connectionSecure = UIImage(named: "icon_https", in: .module, with: nil)!
    
    static let defaultFavicon = UIImage(named: "icon_favicon", in: .module, with: nil)!
    static let cancel = UIImage(named: "icon_cancel", in: .module, with: nil)!
    static let menu = UIImage(named: "icon_hamburger_menu", in: .module, with: nil)!
    static let back = UIImage(named: "icon_back_active", in: .module, with: nil)!
    static let forward = UIImage(named: "icon_forward_active", in: .module, with: nil)!
    static let refresh = UIImage(named: "icon_refresh_menu", in: .module, with: nil)!
    static let stopRefresh = UIImage(named: "icon_stop_menu", in: .module, with: nil)!
    static let delete = UIImage(named: "icon_delete", in: .module, with: nil)!
}
