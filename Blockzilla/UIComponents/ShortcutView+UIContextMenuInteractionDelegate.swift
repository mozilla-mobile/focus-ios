/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import AppShortcuts
import UIKit
import AudioToolbox
import CoreHaptics

extension ShortcutView: UIContextMenuInteractionDelegate {
    
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { _ in
            let renameAction = UIAction(
                title: UIConstants.strings.renameShortcut,
                image: .renameShortcut) { _ in
                    self.delegate?.rename(shortcut: self.shortcut)
                }
            
            let removeFromShortcutsAction = UIAction(
                title: UIConstants.strings.removeFromShortcuts,
                image: .removeShortcut,
                attributes: .destructive) { _ in
                    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                    feedbackGenerator.prepare()
                    CHHapticEngine.capabilitiesForHardware().supportsHaptics ? feedbackGenerator.impactOccurred() : AudioServicesPlaySystemSound(1519)
                    self.delegate?.removeFromShortcutsAction(shortcut: self.shortcut)
                }
            return UIMenu(children: [removeFromShortcutsAction, renameAction])
        })
    }
    
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        contextMenuIsDisplayed =  true
    }
    
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        contextMenuIsDisplayed = false
        self.delegate?.dismissShortcut()
    }
}
