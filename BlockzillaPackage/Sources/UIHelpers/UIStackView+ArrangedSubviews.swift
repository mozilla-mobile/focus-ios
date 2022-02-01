import UIKit

public extension UIStackView {
    func appendArrangedSubview(_ view: UIView) {
        self.insertArrangedSubview(view, at: arrangedSubviews.count)
    }
    func prependArrangedSubview(_ view: UIView) {
        self.insertArrangedSubview(view, at: 0)
    }
}
