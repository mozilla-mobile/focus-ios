//
//  PrivacyProtectionViewController.swift
//  Blockzilla
//
//  Created by razvan.litianu on 07.12.2021.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import UIKit

class PrivacyProtectionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splashView = UIView()
        splashView.backgroundColor = .launchScreenBackground
        view.addSubview(splashView)
        
        let logoImage = UIImageView(image: AppInfo.config.wordmark)
        splashView.addSubview(logoImage)
        
        splashView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        logoImage.snp.makeConstraints { make in
            make.center.equalTo(splashView)
        }
    }
}
