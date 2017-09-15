/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import AutocompleteTextField

protocol AddCustomDomainDelegate {
    func addCustomDomainViewController(_ addCustomDomainViewController: AddCustomDomainViewController, domain: String)
}

class AddCustomDomainViewController: UIViewController, UITextViewDelegate {
    private var delegate: AddCustomDomainDelegate
    private var textView = UITextView()
    
    init(delegate: AddCustomDomainDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = UIConstants.strings.settingsAddDomain
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.strings.cancel, style: .plain, target: self, action: #selector(AddCustomDomainViewController.cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AddCustomDomainViewController.doneTapped))
        
        view.backgroundColor = UIConstants.colors.background
        view.addSubview(textView)
        
        textView.keyboardType = .URL
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.returnKeyType = .done
        textView.textColor = UIColor.white
        textView.delegate = self
        textView.becomeFirstResponder()
        textView.backgroundColor = UIConstants.colors.background
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.height.equalTo(40)
            make.width.equalToSuperview()
        }
    }
    
    @objc func cancelTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneTapped() {
        self.resignFirstResponder()
        delegate.addCustomDomainViewController(self, domain: textView.text)
        self.navigationController?.popViewController(animated: true)
    }
}
