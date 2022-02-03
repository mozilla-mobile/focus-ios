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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        urlBar.viewModel.currentSelection.send(.selected)
    }

    @IBAction func browse(_ sender: Any) {
        urlBar.viewModel.browsingState.send(.browsing)
    }
    
    @IBAction func home(_ sender: Any) {
        urlBar.viewModel.browsingState.send(.home)
    }
    
}

