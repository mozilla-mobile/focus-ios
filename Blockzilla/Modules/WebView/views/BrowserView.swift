//
//  BrowserView.swift
//  Blockzilla
//
//  Created by Jeff Boek on 9/19/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class BrowserView: UIView {
    private let webView = WKWebView(frame: .zero)
    
    convenience init() {
        self.init(frame: .zero)
        addSubview(webView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
    }
}
