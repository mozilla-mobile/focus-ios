/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import LocalAuthentication

class TipManager {
    
    struct Tip: Equatable {
        var title: String
        var description: String?
        var identifier: String
        var vcToDisplay: UIViewController?
        
        init(title: String, description: String? = nil, identifier: String, vcToDisplay: UIViewController? = nil) {
            self.title = title
            self.identifier = identifier
            self.description = description
            self.vcToDisplay = vcToDisplay
        }
        
        static func == (lhs: Tip, rhs: Tip) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    class TipKey {
        static let autocompleteTip = "autocompleteTip"
        static let sitesNotWorkingTip = "sitesNotWorkingTip"
        static let biometricTip = "biometricTip"
        static let siriFavoriteTip = "siriFavoriteTip"
        static let shareTrackersTip = "shareTrackersTip"
        static let requestDesktopTip = "requestDesktopTip"
        static let siriEraseTip = "siriEraseTip"
    }
    
    private var possibleTips: [Tip]
    private let laContext = LAContext()
    
    init() {
        possibleTips = [Tip]()
        addAllTips()
    }
    
    private func addAllTips() {
        possibleTips.append(autocompleteTip)
        possibleTips.append(sitesNotWorkingTip)
        possibleTips.append(requestDesktopTip)
        possibleTips.append(shareTrackersTip)
        
        if laContext.biometryType == .touchID || laContext.biometryType == .faceID {
            possibleTips.append(biometricTip)
        }
        
        if #available(iOS 12.0, *) {
            possibleTips.append(siriFavoriteTip)
            possibleTips.append(siriEraseTip)
        }
    }
    
    lazy var autocompleteTip = Tip(title: "Autocomplete URLs for the sites you use most", description: "Long-press any URL in the address bar", identifier: TipKey.autocompleteTip)
    
    lazy var sitesNotWorkingTip = Tip(title: "Site acting strange?", description: "Try turning off Tracking Protection", identifier: TipKey.sitesNotWorkingTip)
    
    lazy var biometricTip: Tip = {
        let titleString = String(format: "Lock %@ even when a site is open", AppInfo.productName)
        if laContext.biometryType == .faceID {
            return Tip(title: titleString, description: "Turn on Face ID", identifier: TipKey.biometricTip)
        }
        else {
            return Tip(title: titleString, description: "Turn on Touch ID", identifier: TipKey.biometricTip)
        }
    }()
    
    lazy var requestDesktopTip = Tip(title: "Get the full desktop site instead", description: "Page Actions > Request Desktop Site", identifier: TipKey.requestDesktopTip)
    
    @available(iOS 12.0, *)
    lazy var siriFavoriteTip = Tip(title: "Open your favorite site with Siri:", description: "Test", identifier: TipKey.siriFavoriteTip, vcToDisplay: SiriFavoriteViewController())
    
    @available(iOS 12.0, *)
    lazy var siriEraseTip = Tip(title: String(format: "Ask Siri to erase %@ history", AppInfo.productName), description: "Add Siri shortcut", identifier: TipKey.siriEraseTip)
    
    lazy var shareTrackersTip = Tip(title: "%@ trackers blocked so far", identifier: TipKey.shareTrackersTip)
    
    func fetchTip() -> Tip? {
        guard let tip = possibleTips.randomElement(), let indexToRemove = possibleTips.index(of: tip) else { return nil }
        possibleTips.remove(at: indexToRemove)
        if canShowTip(with: tip.identifier) {
            return tip
        }
        else {
            return fetchTip()
        }
    }
    
    private func canShowTip(with id: String) -> Bool {
        let defaults = UserDefaults.standard
        switch id {
        case TipKey.siriFavoriteTip:
            guard #available(iOS 12.0, *) else { return false }
        default:
            break
        }
        return defaults.bool(forKey: id)
    }

}
