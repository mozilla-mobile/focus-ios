/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

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
        static let searchEngineTip = "searchEngineTip"
        static let sitesNotWorkingTip = "sitesNotWorkingTip"
        static let biometricTip = "biometricTip"
        static let siriFavoriteTip = "siriFavoriteTip"
        static let shareTrackersTip = "shareTrackersTip"
    }
    
    private var possibleTips: [Tip]
    
    init() {
        possibleTips = [Tip]()
        addAllTips()
    }
    
    private func addAllTips() {
        possibleTips.append(searchEngineTip)
        possibleTips.append(searchEngineTip)
        possibleTips.append(sitesNotWorkingTip)
        possibleTips.append(biometricTip)
        if #available(iOS 12.0, *) {
            possibleTips.append(siriFavoriteTip)
        }
        possibleTips.append(shareTrackersTip)
    }
    
    lazy var autocompleteTip = Tip(title: "Autocomplete your favorite URLs:", description: "Test", identifier: TipKey.autocompleteTip)
    lazy var searchEngineTip = Tip(title: "Use a different search engine:", description: "Test", identifier: TipKey.searchEngineTip)
    lazy var sitesNotWorkingTip = Tip(title: "Sites not working as expected? Fix it:", description: "Test", identifier: TipKey.sitesNotWorkingTip)
    lazy var biometricTip = Tip(title: "Lock the browser when a site is open:", description: "Test", identifier: TipKey.biometricTip)
    @available(iOS 12.0, *)
    lazy var siriFavoriteTip = Tip(title: "Open your favorite site with Siri:", description: "Test", identifier: TipKey.siriFavoriteTip, vcToDisplay: SiriFavoriteViewController())
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
