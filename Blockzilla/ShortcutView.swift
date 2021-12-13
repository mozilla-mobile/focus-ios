/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import AudioToolbox
import CoreHaptics

protocol ShortcutViewDelegate: AnyObject {
    func shortcutTapped(shortcut: Shortcut)
    func removeFromShortcutsAction(shortcut: Shortcut)
}

class ShortcutView: UIView {
    private var shortcut: Shortcut?
    weak var delegate: ShortcutViewDelegate?
    
    init(shortcut: Shortcut, isIpad: Bool) {
        let dimension = isIpad ? UIConstants.layout.shortcutViewWidthIPad : UIConstants.layout.shortcutViewWidth
        let innerDimension = isIpad ? UIConstants.layout.shortcutViewInnerDimensionIPad :  UIConstants.layout.shortcutViewInnerDimension
        let height = isIpad ? UIConstants.layout.shortcutViewHeightIPad :  UIConstants.layout.shortcutViewHeight
        
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: 0, y: 0, width: dimension, height: height)
        
        self.shortcut = shortcut
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tap)
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: dimension, height: dimension))
        outerView.backgroundColor = .above
        outerView.layer.cornerRadius = 8
        addSubview(outerView)
        outerView.snp.makeConstraints { make in
            make.width.height.equalTo(dimension)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let innerView = UIView(frame: CGRect(x: 0, y: 0, width: innerDimension, height: innerDimension))
        innerView.backgroundColor = .foundation
        innerView.layer.cornerRadius = 4
        outerView.addSubview(innerView)
        innerView.snp.makeConstraints { make in
            make.width.height.equalTo(innerDimension)
            make.center.equalTo(outerView)
        }
        
        let letterLabel = UILabel()
        letterLabel.textColor = .primaryText
        letterLabel.font = .title20
        letterLabel.text = ShortcutsManager.shared.firstLetterFor(shortcut: shortcut)
        innerView.addSubview(letterLabel)
        letterLabel.snp.makeConstraints { make in
            make.center.equalTo(innerView)
        }
        
        let nameLabel = UILabel()
        nameLabel.textColor = .primaryText
        nameLabel.font = .footnote12
        nameLabel.text = ShortcutsManager.shared.nameFor(shortcut: shortcut)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(outerView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        outerView.addInteraction(interaction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTap() {
        if let shortcut = self.shortcut {
            delegate?.shortcutTapped(shortcut: shortcut)
        }
    }
    
}

extension ShortcutView: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { suggestedActions in
            
            let removeFromShortcutsAction = UIAction(title: UIConstants.strings.removeFromShortcuts,
                                                     image: UIImage(named: "icon_shortcuts_remove")) { [weak self] action in
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.prepare()
                if let shortcut = self?.shortcut {
                    CHHapticEngine.capabilitiesForHardware().supportsHaptics ? feedbackGenerator.impactOccurred() : AudioServicesPlaySystemSound(1519)
                    self?.delegate?.removeFromShortcutsAction(shortcut: shortcut)
                }
            }
            return UIMenu(title: "", children: [removeFromShortcutsAction])
        })
    }
}
