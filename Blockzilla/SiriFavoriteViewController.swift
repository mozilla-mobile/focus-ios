/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Intents
import IntentsUI

class SiriFavoriteViewController: UIViewController {
    private let inputLabel = SmartLabel()
    private let textInput: UITextField = InsetTextField(insetBy: 10)
    private let inputDescription = SmartLabel()
    private var addedToSiri: Bool = false {
        didSet {
            setupChangeableUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard #available(iOS 12.0, *) else { return }
        SiriShortcuts().hasAddedActivity(type: .openURL) { (result: Bool) in
            self.addedToSiri = result
        }
    }
    
    override func viewDidLoad() {
        guard #available(iOS 12.0, *) else { return }
        title = UIConstants.strings.favoriteUrlTitle
        view.backgroundColor = UIConstants.colors.background
        
        inputLabel.text = UIConstants.strings.urlToOpen
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
        if let storedFavorite = UserDefaults.standard.value(forKey: "favoriteUrl") as? String {
            textInput.text = storedFavorite
        } else {
            textInput.attributedPlaceholder = NSAttributedString(string: UIConstants.strings.autocompleteAddCustomUrlPlaceholder, attributes: [.foregroundColor: UIConstants.colors.inputPlaceholder])
        }
        
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.strings.cancel, style: .plain, target: self, action: #selector(SiriFavoriteViewController.cancelTapped))
    }
    
    private func setupChangeableUI() {
        let nextButton = UIBarButtonItem(title: UIConstants.strings.NextIntroButtonTitle, style: .done, target: self, action: #selector(SiriFavoriteViewController.nextTapped))
        nextButton.accessibilityIdentifier = "nextButton"
        let doneButton = UIBarButtonItem(title: UIConstants.strings.Done, style: .done, target: self, action: #selector(SiriFavoriteViewController.doneTapped))
        nextButton.accessibilityIdentifier = "doneButton"
        self.navigationItem.rightBarButtonItem = addedToSiri ? doneButton : nextButton
        
        guard addedToSiri else { return }
        let editView = UIView()
        editView.backgroundColor = UIConstants.colors.cellBackground
        view.addSubview(editView)
        
        editView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(inputDescription.snp.bottom).offset(40)
        }
        
        let editLabel = UILabel()
        editLabel.text = "Re-record or Delete Shortcut"
        editLabel.textColor = UIConstants.Photon.Magenta60
        
        editView.addSubview(editLabel)
        editLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        let topBorder = UIView()
        topBorder.backgroundColor = .white
        editView.addSubview(topBorder)
        topBorder.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.width.equalToSuperview()
        }
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = .white
        editView.addSubview(bottomBorder)
        bottomBorder.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.width.equalToSuperview()
        }
        
    }
    
    @objc func cancelTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneTapped() {
        saveFavorite()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func nextTapped() {
        guard #available(iOS 12.0, *) else { return }
        saveFavorite()
        SiriShortcuts().displayAddToSiri(for: .openURL, in: self)
    }
    
    private func saveFavorite() {
        self.resignFirstResponder()
        guard var domain = textInput.text, !domain.isEmpty else {
            Toast(text: UIConstants.strings.autocompleteAddCustomUrlError).show()
            return
        }
        if !domain.hasPrefix("http://") && !domain.hasPrefix("https://") {
            domain = String(format: "https://%@", domain)
        }
        guard let url = URL(string: domain) else {
            Toast(text: UIConstants.strings.autocompleteAddCustomUrlError).show()
            return
        }
        UserDefaults.standard.set(url.absoluteString, forKey: "favoriteUrl")
    }
}

extension SiriFavoriteViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextTapped()
        return true
    }
}

@available(iOS 12.0, *)
extension SiriFavoriteViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

@available(iOS 12.0, *)
extension SiriFavoriteViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
