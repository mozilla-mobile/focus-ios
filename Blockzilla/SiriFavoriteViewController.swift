/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

class SiriFavoriteViewController: UIViewController, UITextFieldDelegate {
    private let inputLabel = SmartLabel()
    private let textInput: UITextField = InsetTextField(insetBy: 10)
    private let inputDescription = SmartLabel()
    
    override func viewDidLoad() {
        title = UIConstants.strings.favoriteUrl
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.strings.cancel, style: .plain, target: self, action: #selector(SiriFavoriteViewController.cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.save, style: .done, target: self, action: #selector(SiriFavoriteViewController.doneTapped))
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "saveButton"
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIConstants.colors.background
        
        inputLabel.text = UIConstants.strings.favoriteUrl
        inputLabel.font = UIConstants.fonts.settingsInputLabel
        inputLabel.textColor = UIConstants.colors.settingsTextLabel
        view.addSubview(inputLabel)
        
        textInput.backgroundColor = UIConstants.colors.cellBackground
        textInput.keyboardType = .URL
        textInput.autocapitalizationType = .none
        textInput.autocorrectionType = .no
        textInput.returnKeyType = .done
        textInput.textColor = UIColor.white
        textInput.delegate = self
        textInput.attributedPlaceholder = NSAttributedString(string: UIConstants.strings.autocompleteAddCustomUrlPlaceholder, attributes: [.foregroundColor: UIConstants.colors.inputPlaceholder])
        textInput.accessibilityIdentifier = "urlInput"
        textInput.becomeFirstResponder()
        view.addSubview(textInput)
        
        inputDescription.text = UIConstants.strings.autocompleteAddCustomUrlExample
        inputDescription.textColor = UIConstants.colors.settingsTextLabel
        inputDescription.font = UIConstants.fonts.settingsDescriptionText
        view.addSubview(inputDescription)
        
        inputLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
        
        textInput.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(inputLabel.snp.bottom).offset(10)
        }
        
        inputDescription.snp.makeConstraints { make in
            make.top.equalTo(textInput.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
    }
    
    @objc func cancelTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneTapped() {
        print("done")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("done")
//        doneTapped()
        return true
    }
}
