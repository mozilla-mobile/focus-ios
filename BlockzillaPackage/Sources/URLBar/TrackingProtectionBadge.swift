import UIKit

class TrackingProtectionBadge: UIView {
    let trackingProtectionOff = UIImageView(image: .trackingProtectionOff)
    let trackingProtectionOn = UIImageView(image: .trackingProtectionOn)
    let connectionNotSecure = UIImageView(image: .connectionNotSecure)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setupViews()
    }
    
    func setupViews() {
        trackingProtectionOff.alpha = 0
        connectionNotSecure.alpha = 0
        trackingProtectionOn.contentMode = .scaleAspectFit
        trackingProtectionOff.contentMode = .scaleAspectFit
        connectionNotSecure.contentMode = .scaleAspectFit
        
        addSubview(trackingProtectionOff)
        addSubview(trackingProtectionOn)
        addSubview(connectionNotSecure)
        
        trackingProtectionOn.setContentHuggingPriority(.required, for: .horizontal)
        trackingProtectionOn.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIConstants.layout.urlBarButtonImageSize)
        }
        
        trackingProtectionOff.setContentHuggingPriority(.required, for: .horizontal)
        trackingProtectionOff.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIConstants.layout.urlBarButtonImageSize)
        }
        
        connectionNotSecure.setContentHuggingPriority(.required, for: .horizontal)
        connectionNotSecure.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(UIConstants.layout.urlBarButtonImageSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateState(trackingStatus: TrackingProtectionStatus, shouldDisplayShieldIcon: Bool) {
        guard shouldDisplayShieldIcon else {
            trackingProtectionOn.alpha = 0
            trackingProtectionOff.alpha = 0
            connectionNotSecure.alpha = 1
            return
        }
        switch trackingStatus {
        case .on:
            trackingProtectionOff.alpha = 0
            trackingProtectionOn.alpha = 1
            connectionNotSecure.alpha = 0
        default:
            trackingProtectionOff.alpha = 1
            trackingProtectionOn.alpha = 0
            connectionNotSecure.alpha = 0
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(UIConstants.layout.shieldIconSize), height:  CGFloat(UIConstants.layout.shieldIconSize))
    }
}
