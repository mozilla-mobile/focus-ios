// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class CollapsedTrackingProtectionBadge: TrackingProtectionBadge {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func setupViews() {
        addSubview(trackingProtectionOff)
        addSubview(trackingProtectionOn)
        addSubview(connectionNotSecure)

        trackingProtectionOn.snp.makeConstraints { make in
            make.leading.centerY.equalTo(self)
            make.width.height.equalTo(UIConstants.layout.trackingProtectionHeight)
        }

        trackingProtectionOff.snp.makeConstraints { make in
            make.leading.centerY.equalTo(self)
            make.width.height.equalTo(UIConstants.layout.trackingProtectionHeight)
        }

        connectionNotSecure.snp.makeConstraints { make in
            make.leading.centerY.equalTo(self)
            make.width.height.equalTo(UIConstants.layout.trackingProtectionHeight)
        }
    }

    override func updateState(trackingStatus: TrackingProtectionStatus, shouldDisplayShieldIcon: Bool) {
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

