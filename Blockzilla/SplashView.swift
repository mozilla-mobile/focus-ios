//
//  SplashView.swift
//  Blockzilla
//
//  Created by razvan.litianu on 09.12.2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import UIKit

class SplashView: UIView {
    
    private let logoImage = UIImageView(image: AppInfo.config.wordmark)

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    private func commonInit() {
        backgroundColor = .launchScreenBackground
        addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    func animateDissapear(_ duration: Double = 0.25) {
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            self.logoImage.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0)
        }, completion: { success in
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                self.alpha = 0
                self.logoImage.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
            }, completion: { success in
                self.isHidden = true
                self.logoImage.layer.transform = CATransform3DIdentity
            })
        })
    }
}
