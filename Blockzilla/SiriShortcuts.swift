/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Intents
import IntentsUI

class SiriShortcuts {
    enum activityType: String {
        case erase
        case eraseAndOpen = "org.mozilla.ios.Klar.eraseAndOpen"
        case openURL = "org.mozilla.ios.Klar.openUrl"
    }
    
    func getActivity(for type: activityType) -> NSUserActivity? {
        switch type {
        case .eraseAndOpen:
            return eraseAndOpenActivity
        case .openURL:
            return openUrlActivity
        default:
            break
        }
        return nil
    }
    
    private var eraseAndOpenActivity: NSUserActivity? = {
        if #available(iOS 12.0, *) {
            let activity = NSUserActivity(activityType: activityType.eraseAndOpen.rawValue)
            activity.title = UIConstants.strings.eraseAndOpenSiri
            activity.userInfo = [:]
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.suggestedInvocationPhrase = UIConstants.strings.eraseAndOpenSiri
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(activityType.eraseAndOpen.rawValue)
            return activity
        } else {
            return nil
        }
    }()
    
    private var openUrlActivity: NSUserActivity? = {
        if #available(iOS 12.0, *) {
            guard let url = UserDefaults.standard.value(forKey: "favoriteUrl") as? String else { return nil }
            let activity = NSUserActivity(activityType: activityType.openURL.rawValue)
            activity.title = UIConstants.strings.openUrlSiri
            activity.userInfo = ["url": url]
            activity.isEligibleForSearch = false
            activity.isEligibleForPrediction = true
            activity.suggestedInvocationPhrase = UIConstants.strings.openUrlSiri
            activity.persistentIdentifier = NSUserActivityPersistentIdentifier(activityType.openURL.rawValue)
            return activity
        } else {
            return nil
        }
    }()
    
    @available(iOS 12.0, *)
    func hasAddedActivity(type: SiriShortcuts.activityType, _ completion: @escaping (_ result: Bool) -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcuts, error) in
            DispatchQueue.main.async {
                guard let voiceShortcuts = voiceShortcuts else { return }
                let foundShortcut = voiceShortcuts.filter { (attempt) in
                    attempt.shortcut.userActivity?.activityType == type.rawValue
                    }.first
                completion(foundShortcut != nil)
            }
        }
    }
    
    @available(iOS 12.0, *)
    func displayAddToSiri(for activityType: activityType, in viewController: UIViewController) {
        guard let activity = SiriShortcuts().getActivity(for: activityType) else { return }
        let shortcut = INShortcut(userActivity: activity)
        let addViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        addViewController.modalPresentationStyle = .formSheet
        addViewController.delegate = viewController as? INUIAddVoiceShortcutViewControllerDelegate
        viewController.present(addViewController, animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func displayEditSiri(for shortcut: INVoiceShortcut, in viewController: UIViewController) {
        let editViewController = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
        editViewController.modalPresentationStyle = .formSheet
        editViewController.delegate = viewController as? INUIEditVoiceShortcutViewControllerDelegate
        viewController.present(editViewController, animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func manageSiri(for activityType: SiriShortcuts.activityType, in viewController: UIViewController) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcuts, error) in
            DispatchQueue.main.async {
                guard let voiceShortcuts = voiceShortcuts else { return }
                let foundShortcut = voiceShortcuts.filter { (attempt) in
                    attempt.shortcut.userActivity?.activityType == activityType.rawValue
                    }.first
                if let foundShortcut = foundShortcut {
                    self.displayEditSiri(for: foundShortcut, in: viewController)
                } else {
                    self.displayAddToSiri(for: activityType, in: viewController)
                }
            }
        }
    }
}
