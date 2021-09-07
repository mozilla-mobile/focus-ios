/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import LocalAuthentication

class TipManager {

    struct Tip: Equatable {
        enum ScrollDestination {
            case siri
            case biometric
            case siriFavorite
        }
        
        enum Action {
            case visit(topic: SupportTopic)
            case showSettings(destination: ScrollDestination)
        }
        
        let title: String
        let description: String?
        let identifier: String
        let action: Action?
        let canShow: () -> Bool

        init(
            title: String,
            description: String? = nil,
            identifier: String,
            action: Action? = nil,
            canShow: @escaping () -> Bool
        ) {
            self.title = title
            self.identifier = identifier
            self.description = description
            self.action = action
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
    private var tips: [Tip] {
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
    }
    
    private var availableTips: [Tip] {
        guard Settings.getToggle(.showHomeScreenTips) else { return [] }
        return tips.filter { $0.canShow() }
    }
    private let laContext = LAContext()
    var currentTip: Tip?

    private init() { }

    private lazy var releaseTip = Tip(
        title: String(format: UIConstants.strings.releaseTipTitle, AppInfo.config.productName),
        description: String(format: UIConstants.strings.releaseTipDescription, AppInfo.config.productName),
        identifier: TipKey.releaseTip,
        action: .visit(topic: .whatsNew),
        canShow: { UserDefaults.standard.bool(forKey: TipKey.releaseTip) }
    )
    
    private lazy var shortcutsTip = Tip(
        title: UIConstants.strings.shortcutsTipTitle,
        description: String(format: UIConstants.strings.shortcutsTipDescription, AppInfo.config.productName),
        identifier: TipKey.shortcutsTip,
        canShow: { UserDefaults.standard.bool(forKey: TipKey.shortcutsTip) }
    )

    private lazy var sitesNotWorkingTip = Tip(
        title: UIConstants.strings.sitesNotWorkingTipTitle,
        description: UIConstants.strings.sitesNotWorkingTipDescription,
        identifier: TipKey.sitesNotWorkingTip,
        canShow: { UserDefaults.standard.bool(forKey: TipKey.sitesNotWorkingTip) }
    )

    private lazy var biometricTip: Tip = {
        let description = laContext.biometryType == .faceID
            ? UIConstants.strings.biometricTipFaceIdDescription
            : UIConstants.strings.biometricTipTouchIdDescription
        
        return Tip(
            title: UIConstants.strings.biometricTipTitle,
            description: description,
            identifier: TipKey.biometricTip,
            action: .showSettings(destination: .biometric),
            canShow: { UserDefaults.standard.bool(forKey: TipKey.biometricTip) }
        )
    }()

    private lazy var requestDesktopTip = Tip(
        title: UIConstants.strings.requestDesktopTipTitle,
        description: UIConstants.strings.requestDesktopTipDescription,
        identifier: TipKey.requestDesktopTip,
        canShow: { UserDefaults.standard.bool(forKey: TipKey.requestDesktopTip) }
    )

    private lazy var siriFavoriteTip = Tip(
        title: UIConstants.strings.siriFavoriteTipTitle,
        description: UIConstants.strings.siriFavoriteTipDescription,
        identifier: TipKey.siriFavoriteTip,
        action: .showSettings(destination: .siri),
        canShow: self.isiOS12
    )

    private lazy var siriEraseTip = Tip(
        title: UIConstants.strings.siriEraseTipTitle,
        description: UIConstants.strings.siriEraseTipDescription,
        identifier: TipKey.siriEraseTip,
        action: .showSettings(destination: .siriFavorite),
        canShow: self.isiOS12
    )

    /// Return a string representing the trackers tip. It will include the current number of trackers blocked, formatted as a decimal.
    func shareTrackersDescription() -> String {
        let numberOfTrackersBlocked = NSNumber(integerLiteral: UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey))
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return String(format: UIConstants.strings.shareTrackersTipDescription, formatter.string(from: numberOfTrackersBlocked) ?? "0")
    }
    
    private var shareTrackersTip: Tip {
        Tip(
            title: UIConstants.strings.shareTrackersTipTitle,
            description: shareTrackersDescription(),
            identifier: TipKey.shareTrackersTip,
            canShow: { UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey) >= 10 }
        )
    }

    func fetchTip() -> Tip? {
        return availableTips.first
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
            if let index = availableTips.firstIndex(where: {$0.identifier == id}) {
                currentTip = index == availableTips.count - 1 ? availableTips[0] : availableTips[index + 1]
                if let currentTip = currentTip {
                    return currentTip
                }
            }
        }
        return nil
    }
    
    func getPreviousTip() -> Tip? {
        if let id = currentTip?.identifier {
            if let index = availableTips.firstIndex(where: {$0.identifier == id}) {
                currentTip = index == 0 ? availableTips.last : availableTips[index - 1]
                if let currentTip = currentTip {
                    return currentTip
                }
            }
        }
        return nil
    }
    
    func numberOfTips() -> Int {
        availableTips.count
    }
    
    func currentTipIndex() -> Int {
        if let id = currentTip?.identifier {
            if let index = availableTips.firstIndex(where: {$0.identifier == id}) {
                return index
            }
        }
        return 0
    }
}
