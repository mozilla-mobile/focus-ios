// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

public extension UIStackView {
    func appendArrangedSubview(_ view: UIView) {
        self.insertArrangedSubview(view, at: arrangedSubviews.count)
    }
    func prependArrangedSubview(_ view: UIView) {
        self.insertArrangedSubview(view, at: 0)
    }
}

public extension UIView {
    func fadeIn(animated: Bool = true, firstDo: (() -> Void)? = nil, thenDo:  (() -> Void)? = nil) {
        if animated {
            firstDo?()
            UIView.transition(with: self, duration: 0.2,
                              options: [],
                              animations: {
                self.isHidden = false
                self.alpha = 1
            }) { _ in
                thenDo?()
            }
        } else {
            firstDo?()
            self.isHidden = false
            self.alpha = 1
            thenDo?()
        }
    }

    func fadeOut(animated: Bool = true, firstDo: (() -> Void)? = nil, thenDo:  (() -> Void)? = nil) {
        if animated {
            firstDo?()
            UIView.transition(with: self, duration: 0.2,
                             options: [],
                             animations: {
                self.isHidden = true
                self.alpha = 0
            }) { _ in
                thenDo?()
            }
        } else {
            firstDo?()
            self.isHidden = true
            self.alpha = 0
            thenDo?()
        }
    }

    func animateHideFromSuperview(thenDo:  (() -> Void)? = nil) {
        fadeOut(thenDo: {
            self.removeFromSuperview()
            thenDo?()
        })
    }
}
