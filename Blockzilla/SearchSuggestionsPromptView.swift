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
    private let promptLabel = UILabel()
    private let enableButton = InsetButton()
    private let disableButton = InsetButton()
    private let buttonTopBorder = UIView()
    private let buttonSideBorder = UIView()
    
    init() {
        super.init(frame: CGRect.zero)
        
        // promptContainer
        promptContainer.backgroundColor = UIConstants.colors.settingsNavBar
        promptContainer.layer.cornerRadius = 8.0
        addSubview(promptContainer)
        
        promptContainer.snp.makeConstraints{ make in
            make.top.equalTo(self).offset(8)
            make.leading.equalTo(self).offset(5)
            make.bottom.equalTo(self).offset(-8)
            make.trailing.equalTo(self).offset(-5)
            make.centerX.centerY.equalTo(self)
        }
        
        // promptLabel
        promptLabel.text = "Show Search Suggestions?"
        promptLabel.textColor = UIConstants.colors.settingsTextLabel
        promptLabel.font = UIConstants.fonts.settingsInputLabel
        //promptLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        promptContainer.addSubview(promptLabel)

        promptLabel.snp.makeConstraints{ make in
            make.centerX.centerY.equalTo(promptContainer)
        }
        
        // buttonTopBorder
        buttonTopBorder.backgroundColor = UIConstants.colors.settingsNavBorder
        addSubview(buttonTopBorder)
        
        buttonTopBorder.snp.makeConstraints {make in
            make.leading.trailing.equalTo(promptContainer)
            make.top.equalTo(promptLabel.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        // buttonSideBorder
        buttonSideBorder.backgroundColor = UIConstants.colors.settingsNavBorder
        addSubview(buttonSideBorder)
        
        buttonSideBorder.snp.makeConstraints {make in
            make.top.equalTo(buttonTopBorder.snp.bottom)
            make.bottom.equalTo(promptContainer.snp.bottom)
            make.height.equalTo(50)
            make.width.equalTo(0.5)
            make.centerX.equalTo(self)
        }

        
        // disableButton
        disableButton.accessibilityIdentifier = "SearchSuggestionsPromptView.disableButton"
        disableButton.backgroundColor = UIConstants.colors.settingsNavBar
        disableButton.setTitle("No", for: .normal)
        disableButton.titleLabel?.font = UIConstants.fonts.settingsInputLabel
        disableButton.layer.cornerRadius = 8.0
        addSubview(disableButton)

        disableButton.snp.makeConstraints { make in
            make.top.equalTo(buttonTopBorder.snp.bottom)
            make.leading.equalTo(promptContainer.snp.leading)
            make.bottom.equalTo(promptContainer.snp.bottom)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        // enableButton
        enableButton.accessibilityIdentifier = "SearchSuggestionsPromptView.enableButton"
        enableButton.backgroundColor = UIConstants.colors.settingsNavBar
        enableButton.setTitle("Yes", for: .normal)
        enableButton.titleLabel?.font = UIConstants.fonts.settingsInputLabel
        enableButton.layer.cornerRadius = 8.0
        addSubview(enableButton)

        enableButton.snp.makeConstraints { make in
            make.top.equalTo(buttonTopBorder.snp.bottom)
            make.trailing.equalTo(promptContainer.snp.trailing)
            make.bottom.equalTo(promptContainer.snp.bottom)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
    }
    
    
    
    // what is this
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
