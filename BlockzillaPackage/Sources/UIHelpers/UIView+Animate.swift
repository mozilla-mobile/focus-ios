import UIKit

public extension UIView {
    func animateShow(firstDo: (() -> Void)? = nil, thenDo:  (() -> Void)? = nil) {
        firstDo?()
        UIView.animate(withDuration: 0.2) {
            self.isHidden = false
            self.alpha = 1
        } completion: { _ in
            thenDo?()
        }
    }
    
    func animateHide(firstDo: (() -> Void)? = nil, thenDo:  (() -> Void)? = nil) {
        firstDo?()
        UIView.animate(withDuration: 0.2) {
            self.isHidden = true
            self.alpha = 0
        } completion: { _ in
            thenDo?()
        }
    }
    
    func animateHideFromSuperview() {
        animateHide(thenDo: {
            self.removeFromSuperview()
        })
    }
}
