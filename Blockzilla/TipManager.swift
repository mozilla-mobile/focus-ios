/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import LocalAuthentication

class TipManager {

    struct Tip: Equatable {
        let title: String
        let description: String?
        let identifier: String
        let showVc: Bool
        let canShow:   () -> Bool

        init(
            title: String,
            description: String? = nil,
            identifier: String,
            showVc: Bool = false,
            canShow: @escaping () -> Bool
        ) {
            self.title = title
            self.identifier = identifier
            self.description = description
            self.showVc = showVc
            self.canShow = canShow
        }

        static func == (lhs: Tip, rhs: Tip) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }

    enum TipKey {
        static let releaseTip = "releaseTip"
        static let shortcutsTip = "shortcutsTip"
        static let sitesNotWorkingTip = "sitesNotWorkingTip"
        static let biometricTip = "biometricTip"
        static let siriFavoriteTip = "siriFavoriteTip"
        static let shareTrackersTip = "shareTrackersTip"
        static let requestDesktopTip = "requestDesktopTip"
        static let siriEraseTip = "siriEraseTip"
    }

    static let shared = TipManager()
    private lazy var possibleTips: [Tip] = {
        var tips: [Tip] = []
        tips.append(releaseTip)
        tips.append(shortcutsTip)
        tips.append(sitesNotWorkingTip)
        tips.append(requestDesktopTip)
        tips.append(siriFavoriteTip)
        tips.append(siriEraseTip)
        tips.append(shareTrackersTip)
        if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            tips.append(biometricTip)
        }
        return tips
    }()
    private let laContext = LAContext()
    var currentTip: Tip?

    private init() { }

    lazy var releaseTip = Tip(title: String(format: UIConstants.strings.releaseTipTitle, AppInfo.config.productName), description: String(format: UIConstants.strings.releaseTipDescription, AppInfo.config.productName), identifier: TipKey.releaseTip, showVc: true) { UserDefaults.standard.bool(forKey: TipKey.releaseTip) }
    
    lazy var shortcutsTip = Tip(title: UIConstants.strings.shortcutsTipTitle, description: String(format: UIConstants.strings.shortcutsTipDescription, AppInfo.config.productName), identifier: TipKey.shortcutsTip) { UserDefaults.standard.bool(forKey: TipKey.shortcutsTip) }

    lazy var sitesNotWorkingTip = Tip(title: UIConstants.strings.sitesNotWorkingTipTitle, description: UIConstants.strings.sitesNotWorkingTipDescription, identifier: TipKey.sitesNotWorkingTip) { UserDefaults.standard.bool(forKey: TipKey.sitesNotWorkingTip) }

    lazy var biometricTip: Tip = {
        if laContext.biometryType == .faceID {
            return Tip(title: UIConstants.strings.biometricTipTitle, description: UIConstants.strings.biometricTipFaceIdDescription, identifier: TipKey.biometricTip, showVc: true) { UserDefaults.standard.bool(forKey: TipKey.biometricTip) }
        } else {
            return Tip(title: UIConstants.strings.biometricTipTitle, description: UIConstants.strings.biometricTipTouchIdDescription, identifier: TipKey.biometricTip, showVc: true) { UserDefaults.standard.bool(forKey: TipKey.biometricTip) }
        }
    }()

    lazy var requestDesktopTip = Tip(title: UIConstants.strings.requestDesktopTipTitle, description: UIConstants.strings.requestDesktopTipDescription, identifier: TipKey.requestDesktopTip) { UserDefaults.standard.bool(forKey: TipKey.requestDesktopTip) }

    lazy var siriFavoriteTip = Tip(title: UIConstants.strings.siriFavoriteTipTitle, description: UIConstants.strings.siriFavoriteTipDescription, identifier: TipKey.siriFavoriteTip, showVc: true, canShow: self.isiOS12)

    lazy var siriEraseTip = Tip(title: UIConstants.strings.siriEraseTipTitle, description: UIConstants.strings.siriEraseTipDescription, identifier: TipKey.siriEraseTip, showVc: true, canShow: self.isiOS12)

    /// Return a string representing the trackers tip. It will include the current number of trackers blocked, formatted as a decimal.
    func shareTrackersDescription() -> String {
        let numberOfTrackersBlocked = NSNumber(integerLiteral: UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey))
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return String(format: UIConstants.strings.shareTrackersTipDescription, formatter.string(from: numberOfTrackersBlocked) ?? "0")
    }
    
    lazy var shareTrackersTip = Tip(title: UIConstants.strings.shareTrackersTipTitle, description: shareTrackersDescription(), identifier: TipKey.shareTrackersTip) {
        UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey) >= 10
    }

    func fetchTip() -> Tip? {
        guard Settings.getToggle(.showHomeScreenTips) else { return shareTrackersTip }
        guard let tip = possibleTips.first else { return nil }
        return tip.canShow() ? tip : nil
    }
    
    private func isiOS12() -> Bool {
        guard #available(iOS 12.0, *) else { return false }
        return true
    }

    func shouldShowTips() -> Bool {
        return NSLocale.current.languageCode == "en" && !AppInfo.isKlar
    }
    
    func getNextTip() -> Tip? {
        if let id = currentTip?.identifier {
            if let index = possibleTips.firstIndex(where: {$0.identifier == id}) {
                currentTip = index == possibleTips.count - 1 ? possibleTips[0] : possibleTips[index + 1]
                if let currentTip = currentTip {
                    return currentTip
                }
            }
        }
        return nil
    }
    
    func getPreviousTip() -> Tip? {
        if let id = currentTip?.identifier {
            if let index = possibleTips.firstIndex(where: {$0.identifier == id}) {
                currentTip = index == 0 ? possibleTips.last : possibleTips[index - 1]
                if let currentTip = currentTip {
                    return currentTip
                }
            }
        }
        return nil
    }
    
    func numberOfTips() -> Int {
        possibleTips.count
    }
    
    func currentTipIndex() -> Int {
        if let id = currentTip?.identifier {
            if let index = possibleTips.firstIndex(where: {$0.identifier == id}) {
                return index
            }
        }
        return 0
    }
}
