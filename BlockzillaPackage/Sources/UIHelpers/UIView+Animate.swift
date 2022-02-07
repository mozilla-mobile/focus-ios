import UIKit

public extension UIView {
    func show(animated: Bool = true, firstDo: (() -> Void)? = nil, thenDo:  (() -> Void)? = nil) {
        if animated {
            firstDo?()
            UIView.animate(withDuration: 0.2) {
                self.isHidden = false
                self.alpha = 1
            } completion: { _ in
                thenDo?()
            }
        } else {
            firstDo?()
            self.isHidden = false
            self.alpha = 1
            thenDo?()
        }
    }
    
    func hide(animated: Bool = true, firstDo: (() -> Void)? = nil, thenDo:  (() -> Void)? = nil) {
        if animated {
            firstDo?()
            UIView.animate(withDuration: 0.2) {
                self.isHidden = true
                self.alpha = 0
            } completion: { _ in
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
        hide(thenDo: {
            self.removeFromSuperview()
            thenDo?()
        })
    }
}
