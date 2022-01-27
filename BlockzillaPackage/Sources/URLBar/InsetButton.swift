import UIKit

class InsetButton: UIButton {
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + titleEdgeInsets.left + titleEdgeInsets.right,
                      height: size.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
    }
    
    var highlightedBackgroundColor: UIColor?
    var savedBackgroundColor: UIColor?
    
    @objc override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                if savedBackgroundColor == nil && backgroundColor != nil {
                    if let color = highlightedBackgroundColor {
                        savedBackgroundColor = backgroundColor
                        backgroundColor = color
                    }
                }
            } else {
                if let color = savedBackgroundColor {
                    backgroundColor = color
                    savedBackgroundColor = nil
                }
            }
        }
    }
}
