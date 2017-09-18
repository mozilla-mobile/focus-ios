/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import AutocompleteTextField

protocol AddCustomDomainDelegate {
    func addCustomDomainViewController(_ addCustomDomainViewController: AddCustomDomainViewController, domain: String)
}

class AddCustomDomainViewController: UIViewController, UITextFieldDelegate {
    private var delegate: AddCustomDomainDelegate
    private var textInput = UITextField()
    
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
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIConstants.colors.background

        
        let container = UIView()
        container.backgroundColor = UIConstants.colors.urlTextBackground
        view.addSubview(container)
        
        let httpLabel = UILabel()
        httpLabel.text = "http://"
        httpLabel.textColor = UIConstants.colors.settingsTextLabel
        
        container.addSubview(httpLabel)
        container.addSubview(textInput)
        
        textInput.keyboardType = .URL
        textInput.autocapitalizationType = .none
        textInput.autocorrectionType = .no
        textInput.returnKeyType = .done
        textInput.textColor = UIColor.white
        textInput.delegate = self
        textInput.placeholder = "mozilla.org"
        textInput.becomeFirstResponder()
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        
        httpLabel.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.left.equalTo(10)
            make.width.equalTo(50)
            make.right.equalTo(httpLabel.snp.left)
        }
        
        textInput.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.left.equalTo(httpLabel.snp.right)
        }
    }
    
    @objc func cancelTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneTapped()
        return true
    }
    
    @objc func doneTapped() {
        self.resignFirstResponder()
        guard let domain = textInput.text else { return }
        if domain.count == 0 {
            return
        }
        
        delegate.addCustomDomainViewController(self, domain: domain)
        self.navigationController?.popViewController(animated: true)
    }
}
