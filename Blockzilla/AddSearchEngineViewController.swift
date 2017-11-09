/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

protocol AddSearchEngineDelegate {
    func addSearchEngineViewController(_ addSearchEngineViewController: AddSearchEngineViewController, name: String, searchTemplate: String)
}

class AddSearchEngineViewController: UIViewController {
    private var delegate: AddSearchEngineDelegate
    
    private let leftMargin = 10
    private let rowHeight = 44
    
    init(delegate: AddSearchEngineDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = UIConstants.strings.AddSearchEngineTitle
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UIConstants.strings.cancel, style: .plain, target: self, action: #selector(AddSearchEngineViewController.cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: UIConstants.strings.Save, style: .plain, target: self, action: #selector(AddSearchEngineViewController.saveTapped))
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIConstants.colors.background
        
        let container = UIView()
        view.addSubview(container)
        
        let nameLabel = UILabel()
        nameLabel.text = UIConstants.strings.NameToDisplay
        nameLabel.textColor = UIConstants.colors.settingsTextLabel
        container.addSubview(nameLabel)
        
        let nameInput = UITextField()
        nameInput.attributedPlaceholder = NSAttributedString(string: UIConstants.strings.AddSearchEngineName, attributes: [NSAttributedStringKey.foregroundColor: UIConstants.colors.settingsDetailLabel])
        nameInput.backgroundColor = UIConstants.colors.cellSelected
        nameInput.textColor = UIConstants.colors.settingsTextLabel
        nameInput.leftView = UIView(frame: CGRect(x: 0, y: 0, width: leftMargin, height: rowHeight))
        nameInput.leftViewMode = .always
        container.addSubview(nameInput)
        
        let templateLabel = UILabel()
        templateLabel.text = UIConstants.strings.AddSearchEngineTemplate
        templateLabel.textColor = UIConstants.colors.settingsTextLabel
        container.addSubview(templateLabel)
        
        let templateInput = UITextView()
        templateInput.backgroundColor = UIConstants.colors.cellSelected
        templateInput.textColor = UIConstants.colors.settingsTextLabel
        container.addSubview(templateInput)
        
        let exampleLabel = UILabel()
        exampleLabel.text = UIConstants.strings.AddSearchEngineTemplateExample
        exampleLabel.textColor = UIConstants.colors.settingsTextLabel
        container.addSubview(exampleLabel)
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.height.equalTo(rowHeight)
            make.leftMargin.equalTo(leftMargin)
            make.width.equalToSuperview()
        }
        
        nameInput.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.height.equalTo(rowHeight)
            make.width.equalToSuperview()
        }
        
        templateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameInput.snp.bottom)
            make.left.equalTo(leftMargin)
            make.height.equalTo(rowHeight)
        }
        
        templateInput.snp.makeConstraints { (make) in
            make.top.equalTo(templateLabel.snp.bottom)
            make.height.equalTo(88)
            make.width.equalToSuperview()
        }
        
        exampleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(templateInput.snp.bottom)
            make.width.equalToSuperview()
            make.left.equalTo(leftMargin)
            make.height.equalTo(rowHeight)
        }
    }
    
    @objc func cancelTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}
