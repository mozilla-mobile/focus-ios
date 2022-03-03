/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class SplashView: UIView {
    
    enum State {
        case needsAuth
        case `default`
    }
    
    var state = State.default {
        didSet {
            self.updateUI()
        }
    }
    
    var authenticationManager: AuthenticationManager! {
        didSet {
            authButton.setImage(
                authenticationManager.biometricType == .faceID ? .faceid : .touchid,
                for: .normal
            )
        }
    }
    
    private let logoImage = UIImageView(image: AppInfo.config.wordmark)
    
    private lazy var authButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addBackgroundView(cornerRadius: 22, padding: 8)
        button.addTarget(self, action:#selector(self.showAuth), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .launchScreenBackground
        addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
        addSubview(authButton)
        authButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImage).inset(100)
            make.height.width.equalTo(44)
        }
        
        updateUI()
    }
    
    private func updateUI() {
        authButton.isHidden = state == .default
    }
    
    @objc private func showAuth() {
        state = .default
        Task {
            await authenticationManager.authenticateWithBiometrics()
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
