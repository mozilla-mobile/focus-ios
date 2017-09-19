//
//  BrowserViewController.swift
//  Blockzilla
//
//  Created by Jeff Boek on 9/19/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    private let browserView = WKWebView()
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = browserView
    }
    
    func load(_ request: URLRequest) {
        browserView.load(request)
    }
}
