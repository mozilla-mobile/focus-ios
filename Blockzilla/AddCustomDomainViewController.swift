/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import AutocompleteTextField

protocol AddCustomDomainDelegate {
    func addCustomDomainViewController(_ addCustomDomainViewController: AddCustomDomainViewController, domain: String)
}

class AddCustomDomainViewController: UIViewController, UITextFieldDelegate {
    private class InputField: UITextField {
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 10, dy: 10)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 10, dy: 10)
        }
    }

    private var delegate: AddCustomDomainDelegate
    private let inputLabel = UILabel()
    private let textInput: UITextField = InputField()
    private let inputDescription = UILabel()
    
    init(delegate: AddCustomDomainDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = UIConstants.strings.autocompleteAddCustomUrl
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.strings.cancel, style: .plain, target: self, action: #selector(AddCustomDomainViewController.cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.save, style: .done, target: self, action: #selector(AddCustomDomainViewController.doneTapped))
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "saveButton"
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIConstants.colors.background

        inputLabel.text = UIConstants.strings.autocompleteAddCustomUrlLabel
        inputLabel.font = UIConstants.fonts.settingsInputLabel
        inputLabel.textColor = UIConstants.colors.settingsTextLabel
        view.addSubview(inputLabel)

        textInput.backgroundColor = UIConstants.colors.urlTextBackground
        textInput.keyboardType = .URL
        textInput.autocapitalizationType = .none
        textInput.autocorrectionType = .no
        textInput.returnKeyType = .done
        textInput.textColor = UIColor.white
        textInput.delegate = self
        textInput.attributedPlaceholder = NSAttributedString(string: UIConstants.strings.autocompleteAddCustomUrlPlaceholder, attributes: [.foregroundColor: UIConstants.colors.inputPlaceholder])
        textInput.accessibilityIdentifier = "urlInput"
        textInput.becomeFirstResponder()
        textInput.editingRect(forBounds: textInput.frame.insetBy(dx: 10, dy: 10))
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneTapped()
        return true
    }
    
    @objc func doneTapped() {
        self.resignFirstResponder()
        guard let domain = textInput.text, !domain.isEmpty else { return }

        delegate.addCustomDomainViewController(self, domain: domain)
        self.navigationController?.popViewController(animated: true)
    }
}
