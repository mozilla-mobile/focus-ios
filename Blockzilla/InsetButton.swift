/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

/**
 * Button whose insets are included in its intrinsic size.
 */
class InsetButton: UIButton {
    init() {
        super.init(frame: CGRect.zero)

        addTarget(self, action: #selector(didTouchDismiss), for: [UIControl.Event.touchDown, UIControl.Event.touchDragEnter])
        addTarget(self, action: #selector(didTouchUpDismiss), for: [UIControl.Event.touchDragExit, UIControl.Event.touchUpInside, UIControl.Event.touchUpOutside])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + titleEdgeInsets.left + titleEdgeInsets.right,
                      height: size.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
    }

    @objc private func didTouchDismiss() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.5
        }
    }

    @objc private func didTouchUpDismiss() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
    }
}
