//
//  ViewController.swift
//  URLBarApp
//
//  Created by razvan.litianu on 26.01.2022.
//  Copyright © 2022 Mozilla. All rights reserved.
//

import UIKit
import URLBar

class ViewController: UIViewController {
    @IBOutlet weak var urlBar: URLBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func browse(_ sender: Any) {
        urlBar.browsingSubject.send(.browsing)
        print("hello")
    }
    
    @IBAction func home(_ sender: Any) {
        urlBar.browsingSubject.send(.home)
        print("hello")
    }
    
}

