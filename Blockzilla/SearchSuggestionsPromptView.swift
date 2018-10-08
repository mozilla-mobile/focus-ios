//
//  SearchSuggestionsPromptView.swift
//  Blockzilla
//
//  Created by Janice Lee on 2018-10-03.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import SnapKit

protocol SearchSuggestionsPromptViewDelegate: class {
    
}

class SearchSuggestionsPromptView: UIView {
    weak var delegate: SearchSuggestionsPromptViewDelegate? // unsure if ? is correct
    private let promptContainer = UIView()
    private let promptTitle = UILabel()
    private let promptMessage = UILabel()
    private let enableButton = InsetButton()
    private let disableButton = InsetButton()
    private let buttonBorderTop = UIView()
    private let buttonBorderMiddle = UIView()
    
    init() {
        super.init(frame: CGRect.zero)
        
        // promptContainer
        promptContainer.backgroundColor = UIConstants.Photon.Ink70.withAlphaComponent(0.9)
        promptContainer.layer.cornerRadius = UIConstants.layout.searchSuggestionsPromptCornerRadius
        addSubview(promptContainer)
        
        promptContainer.snp.makeConstraints{ make in
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-8)
            make.leading.equalTo(self).offset(6)
            make.trailing.equalTo(self).offset(-6)
        }
        
        // promptTitle
        promptTitle.text = UIConstants.strings.searchSuggestionsPromptTitle
        promptTitle.textColor = UIConstants.Photon.Grey10
        promptTitle.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        promptTitle.textAlignment = NSTextAlignment.center
        promptTitle.numberOfLines = 0
        promptTitle.lineBreakMode = .byWordWrapping
        promptContainer.addSubview(promptTitle)

        promptTitle.snp.makeConstraints{ make in
            make.top.equalTo(promptContainer).offset(20)
            make.leading.equalTo(promptContainer).offset(10)
            make.trailing.equalTo(promptContainer).offset(-10)
        }
        
        // promptMessage
        promptMessage.text = UIConstants.strings.searchSuggestionsPromptMessage
        promptMessage.textColor = UIConstants.Photon.Grey10
        promptMessage.font = UIFont.systemFont(ofSize: 14)
        promptMessage.textAlignment = NSTextAlignment.center
        promptMessage.numberOfLines = 0
        promptMessage.lineBreakMode = .byWordWrapping
        promptContainer.addSubview(promptMessage)
        
        promptMessage.snp.makeConstraints { make in
            make.top.equalTo(promptTitle.snp.bottom).offset(5)
            make.leading.equalTo(promptContainer).offset(10)
            make.trailing.equalTo(promptContainer).offset(-10)
        }
        
        // buttonBorderTop
        buttonBorderTop.backgroundColor = UIConstants.Photon.Grey10.withAlphaComponent(0.2)
        addSubview(buttonBorderTop)
        
        buttonBorderTop.snp.makeConstraints { make in
            make.top.equalTo(promptMessage.snp.bottom).offset(20)
            make.leading.trailing.equalTo(promptContainer)
            make.height.equalTo(0.5)
        }
        
        // buttonBorderMiddle
        buttonBorderMiddle.backgroundColor = UIConstants.Photon.Grey10.withAlphaComponent(0.2)
        addSubview(buttonBorderMiddle)
        
        buttonBorderMiddle.snp.makeConstraints { make in
            make.top.equalTo(buttonBorderTop.snp.bottom)
            make.bottom.equalTo(promptContainer)
            make.width.equalTo(0.5)
            make.height.equalTo(40)
            make.centerX.equalTo(self)
        }

        // disableButton
        disableButton.accessibilityIdentifier = "SearchSuggestionsPromptView.disableButton"
        disableButton.setTitle(UIConstants.strings.searchSuggestionsPromptDisable, for: .normal)
        disableButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        disableButton.backgroundColor = UIConstants.Photon.Ink70.withAlphaComponent(0.9)
        disableButton.layer.cornerRadius = 8.0
        addSubview(disableButton)

        disableButton.snp.makeConstraints { make in
            make.top.equalTo(buttonBorderTop.snp.bottom)
            make.bottom.leading.equalTo(promptContainer)
            make.trailing.equalTo(buttonBorderMiddle.snp.leading)
        }
        
        // enableButton
        enableButton.accessibilityIdentifier = "SearchSuggestionsPromptView.enableButton"
        enableButton.setTitle(UIConstants.strings.searchSuggestionsPromptEnable, for: .normal)
        enableButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        enableButton.backgroundColor = UIConstants.Photon.Ink70.withAlphaComponent(0.9)
        enableButton.layer.cornerRadius = 8.0
        addSubview(enableButton)

        enableButton.snp.makeConstraints { make in
            make.top.equalTo(buttonBorderTop.snp.bottom)
            make.bottom.trailing.equalTo(promptContainer)
            make.leading.equalTo(buttonBorderMiddle.snp.trailing)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
