/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

protocol ShortcutViewDelegate: class {
    func shortcutTapped(shortcut: Shortcut)
    func shortcutLongPressed(shortcut: Shortcut, shortcutView: ShortcutView)
}

class ShortcutView: UIView {
    private let dimension = UIConstants.layout.shortcutViewWidth
    private let innerDimension = UIConstants.layout.shortcutViewInnerDimension
    
    private var shortcut: Shortcut?
    weak var delegate: ShortcutViewDelegate?
    
    init(shortcut: Shortcut) {
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: 0, y: 0, width: UIConstants.layout.shortcutViewWidth, height: UIConstants.layout.shortcutViewHeight)
        
        self.shortcut = shortcut
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        self.addGestureRecognizer(longPress)
        
        let firstView = UIView(frame: CGRect(x: 0, y: 0, width: dimension, height: dimension))
        firstView.backgroundColor = .above
        firstView.layer.cornerRadius = 8
        addSubview(firstView)
        firstView.snp.makeConstraints { make in
            make.width.height.equalTo(dimension)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let secondView = UIView(frame: CGRect(x: 0, y: 0, width: innerDimension, height: innerDimension))
        secondView.backgroundColor = .foundation
        secondView.layer.cornerRadius = 4
        addSubview(secondView)
        secondView.snp.makeConstraints { make in
            make.width.height.equalTo(innerDimension)
            make.center.equalTo(firstView)
        }
        
        let letterLabel = UILabel()
        letterLabel.textColor = .primaryText
        letterLabel.font = .systemFont(ofSize: 20)
        letterLabel.text = ShortcutsManager.shared.firstLetterFor(shortcut: shortcut)
        addSubview(letterLabel)
        letterLabel.snp.makeConstraints { make in
            make.center.equalTo(secondView)
        }
        
        let nameLabel = UILabel()
        nameLabel.textColor = .primaryText
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.text = ShortcutsManager.shared.nameFor(shortcut: shortcut)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(firstView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTap() {
        if let shortcut = self.shortcut {
            delegate?.shortcutTapped(shortcut: shortcut)
        }
    }
    
    @objc private func didLongPress() {
        if let shortcut = self.shortcut {
            delegate?.shortcutLongPressed(shortcut: shortcut, shortcutView: self)
        }
    }
}
