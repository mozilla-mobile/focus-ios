/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit

protocol OverlayViewDelegate: class {
    func overlayViewDidTouchEmptyArea(_ overlayView: OverlayView)
    func overlayViewDidPressSettings(_ overlayView: OverlayView)
    func overlayView(_ overlayView: OverlayView, didSearchForQuery query: String)
    func overlayView(_ overlayView: OverlayView, didSubmitText text: String)
    func overlayView(_ overlayView: OverlayView, didSearchOnPage query: String)
}

class IndexedInsetButton: InsetButton {
    private var index: Int = 0

    func setIndex(_ i:Int){
        index = i
    }

    func getIndex() -> Int{
        return index
    }
}

enum ButtonViews: String {
    case searchGroup = "searchGroup"
    case findInPage = "findInPage"
    case searchPrompt = "searchPrompt"
    case copyButton = "copyButton"
    case topBorder = "topBorder"
}

class OverlayView: UIView {
    weak var delegate: OverlayViewDelegate?
    private var searchButtonGroup = [IndexedInsetButton]()
    private let buttonHeight = 56
    private var searchSuggestionsMaxIndex : Int
    private let maxNumberSuggestions = 4
    private var presented = false
    private var searchQueryArray : [String] = []
    private let copyButton = UIButton()
    private let findInPageButton = InsetButton()
    private let searchSuggestionsPrompt = SearchSuggestionsPromptView()
    private let topBorder = UIView()
    private let buttonsInOrder : [ButtonViews] = [.topBorder,.searchPrompt,.findInPage,.copyButton,.searchGroup]
    private var currentExpandedButtons : [ButtonViews] = [.topBorder,.searchPrompt]
    public var currentURL = ""

    init() {
        searchSuggestionsMaxIndex = Settings.getToggle(.enableSearchSuggestions) ? maxNumberSuggestions : 0
        super.init(frame: CGRect.zero)
        KeyboardHelper.defaultHelper.addDelegate(delegate: self)

        //Make All Buttons
        searchSuggestionsPrompt.backgroundColor = UIConstants.colors.background
        searchSuggestionsPrompt.clipsToBounds = true
        addSubview(searchSuggestionsPrompt)

        topBorder.isHidden = true
        topBorder.alpha = 0
        topBorder.backgroundColor = UIConstants.Photon.Grey90.withAlphaComponent(0.4)
        addSubview(topBorder)

        let padding = UIConstants.layout.searchButtonInset
        makeFindInPageButton(withPadding: padding)
        for i in 0...searchSuggestionsMaxIndex {
            makeSearchButton(atIndex: i)
        }
        makeCopyButton(withPadding: padding)

        //Set Constraints
        topBorder.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(1)
        }

        searchSuggestionsPrompt.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(topBorder.snp.bottom)
            //make.height.equalTo(searchSuggestionsPrompt.frame.height)
        }
        
        findInPageButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(searchSuggestionsPrompt.snp.bottom)
            make.height.equalTo(0)
        }
        findInPageButton.animateHidden(true, duration: 0)

        copyButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(findInPageButton.snp.bottom)
            make.height.equalTo(0)
        }
        copyButton.animateHidden(true, duration: 0)

        for i in 0...searchSuggestionsMaxIndex {
            self.searchButtonGroup[i].snp.makeConstraints { make in
                if i == 0 {
                    make.top.equalTo(self.searchSuggestionsPrompt.snp.bottom)
                }
                else {
                    make.top.equalTo(searchButtonGroup[i - 1].snp.bottom)
                }
                make.leading.trailing.equalTo(safeAreaLayoutGuide)
                make.height.equalTo(0)
            }
            self.searchButtonGroup[i].animateHidden(true, duration: 0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeFindInPageButton(withPadding padding:CGFloat) {
        findInPageButton.titleLabel?.font = UIConstants.fonts.copyButton
        findInPageButton.titleEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        findInPageButton.titleLabel?.lineBreakMode = .byTruncatingTail
        findInPageButton.addTarget(self, action: #selector(didPressFindOnPage), for: .touchUpInside)
        findInPageButton.accessibilityIdentifier = "FindInPageBar.button"
        findInPageButton.backgroundColor = UIConstants.colors.background
        if UIView.userInterfaceLayoutDirection(for: findInPageButton.semanticContentAttribute) == .rightToLeft {
            findInPageButton.contentHorizontalAlignment = .right
        } else {
            findInPageButton.contentHorizontalAlignment = .left
        }
        addSubview(findInPageButton)
    }
    
    func makeCopyButton(withPadding padding:CGFloat) {
        copyButton.titleLabel?.font = UIConstants.fonts.copyButton
        copyButton.titleEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        copyButton.titleLabel?.lineBreakMode = .byTruncatingTail
        copyButton.backgroundColor = UIConstants.colors.background
        if UIView.userInterfaceLayoutDirection(for: copyButton.semanticContentAttribute) == .rightToLeft {
            copyButton.contentHorizontalAlignment = .right
        } else {
            copyButton.contentHorizontalAlignment = .left
        }
        copyButton.addTarget(self, action: #selector(didPressCopy), for: .touchUpInside)
        addSubview(copyButton)
    }

    func makeSearchButton(atIndex i: Int) {
        let searchButton = IndexedInsetButton()
        searchButton.accessibilityIdentifier = "OverlayView.searchButton"
        searchButton.alpha = 0
        searchButton.setImage(#imageLiteral(resourceName: "icon_searchfor"), for: .normal)
        searchButton.setImage(#imageLiteral(resourceName: "icon_searchfor"), for: .highlighted)
        searchButton.backgroundColor = UIConstants.colors.background
        searchButton.titleLabel?.font = UIConstants.fonts.searchButton
        searchButton.backgroundColor = UIConstants.colors.background
        setUpOverlayButton(button: searchButton)
        searchButton.setIndex(i)
        searchButton.addTarget(self, action: #selector(didPressSearch(sender:)), for: .touchUpInside)
        searchButtonGroup.append(searchButton)
        addSubview(searchButton)
    }

    func correctNumberOfSearchButtons(by numberOfButtonsToReveal: Int) {
        // Create more buttons if just turned on SearchSuggestions
        if maxNumberSuggestions >= searchButtonGroup.count{
            for i in searchButtonGroup.count...maxNumberSuggestions {
                makeSearchButton(atIndex: i)
                
                self.searchButtonGroup[i].snp.makeConstraints { make in
                    make.top.equalTo(searchButtonGroup[i - 1].snp.bottom)
                    make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    make.height.equalTo(0)
                }
            }
        }
        //Hide Buttons if too many showing
        if numberOfButtonsToReveal < 0 {
            for i in numberOfButtonsToReveal ... -1 {
                let index = searchSuggestionsMaxIndex - i
                searchButtonGroup[index].animateHidden(true, duration: 0)
                searchButtonGroup[index].snp.updateConstraints{ (make) in
                    make.height.equalTo(0)
                }
                if index == 0 {
                    findInPageButton.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                    remakeConstraintsAfterHidingButtons(.findInPage, .searchGroup)
                }
            }
        }
        //Show buttons if some currently hidden
        else if numberOfButtonsToReveal > 0 {
            for i in 0 ... numberOfButtonsToReveal - 1 {
                let index = searchSuggestionsMaxIndex - i
                if index == 0 {
                    remakeConstraintsAfterRevealingButtons(.searchGroup)
                }
                searchButtonGroup[index].animateHidden(false, duration: 0)
                searchButtonGroup[index].snp.updateConstraints { (make) in
                    make.height.equalTo(buttonHeight)
                }
            }
        }
    }

    func getButton(_ button:ButtonViews) -> UIView {
        switch(button) {
        case .copyButton:
            return self.copyButton
        case .findInPage:
            return self.findInPageButton
        case .searchGroup:
            return self.searchButtonGroup[0]
        case .searchPrompt:
            return self.searchSuggestionsPrompt
        case .topBorder:
            return self.topBorder
        }
    }

    func remakeConstraintsAfterHidingButtons(_ buttons: ButtonViews ...) {
        var lowestIndexRemoved:Int = 100
        for button in buttons {
            if let index = currentExpandedButtons.firstIndex(of: button) {
                currentExpandedButtons.remove(at: index)
                lowestIndexRemoved = min(lowestIndexRemoved,index)
            }
        }
        // Only have to move buttons up if a button above them is hidden
        if lowestIndexRemoved < currentExpandedButtons.count {
            moveTheButtons(fromIndex: lowestIndexRemoved)
        }
    }

    func remakeConstraintsAfterRevealingButtons(_ buttons: ButtonViews ...) {
        var lowestIndexAdded:Int = 100
        outer: for button in buttons {
            if currentExpandedButtons.contains(button) {continue}
            var index: Int = 0
            if currentExpandedButtons.count > 0 {
                var bvcurrent = currentExpandedButtons[index]
                for bv in buttonsInOrder {
                    if bv == button {break}
                    if bv == bvcurrent {
                        index = index + 1
                        if currentExpandedButtons.count < index {
                            bvcurrent = currentExpandedButtons[index]
                            continue
                        }
                        break
                    }
                }
            }
            currentExpandedButtons.insert(button, at: index)
            lowestIndexAdded = min(lowestIndexAdded,index)
        }
        moveTheButtons(fromIndex: lowestIndexAdded)
    }

    func moveTheButtons(fromIndex lowestIndexEffected:Int) {
        if lowestIndexEffected >= currentExpandedButtons.count {return}
        for i in lowestIndexEffected...currentExpandedButtons.count - 1 {
            var height = buttonHeight
            if currentExpandedButtons[i] == .topBorder {
                height = 1
            }
            if i == 0 {
                let theButton = getButton(currentExpandedButtons[i])
                theButton.snp.remakeConstraints{ (make) in
                    make.leading.trailing.top.equalTo(safeAreaLayoutGuide)
                    if currentExpandedButtons[i] != .searchPrompt {
                        make.height.equalTo(height)
                    }
                }
            } else {
                let topButton = getButton(currentExpandedButtons[i-1])
                let bottomButton = getButton(currentExpandedButtons[i])
                bottomButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(topButton.snp.bottom)
                    make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    if currentExpandedButtons[i] != .searchPrompt {
                        make.height.equalTo(height)
                    }
                }
                if currentExpandedButtons[i] == .searchGroup && searchSuggestionsMaxIndex > 0 {
                    for index in 1...searchSuggestionsMaxIndex {
                        searchButtonGroup[index].snp.remakeConstraints{ (make) in
                            make.top.equalTo(searchButtonGroup[index-1].snp.bottom)
                            make.leading.trailing.equalTo(safeAreaLayoutGuide)
                            make.height.equalTo(buttonHeight)
                        }
                    }
                }
            }
        }
    }

    func adjustForFindInPage(hidden:Bool){
        if hidden {
            findInPageButton.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            remakeConstraintsAfterHidingButtons(.findInPage)
        } else {
            findInPageButton.snp.updateConstraints { (make) in
                make.height.equalTo(buttonHeight)
            }
            remakeConstraintsAfterRevealingButtons(.findInPage)
        }
    }

    func setUpOverlayButton (button: InsetButton) {
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        if UIView.userInterfaceLayoutDirection(for: button.semanticContentAttribute) == .rightToLeft {
            button.contentHorizontalAlignment = .right
        } else {
            button.contentHorizontalAlignment = .left
        }
        
        let padding = UIConstants.layout.searchButtonInset
        button.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        if UIView.userInterfaceLayoutDirection(for: button.semanticContentAttribute) == .rightToLeft {
            button.titleEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding * 2)
        } else {
            button.titleEdgeInsets = UIEdgeInsets(top: padding, left: padding * 2, bottom: padding, right: padding)
        }
    }
    
    /**
     
     Localize and style 'phrase' text for use as a button title.
     
     - Parameter phrase: The phrase text for a button title
     - Parameter localizedStringFormat: The localization format string to apply
     
     - Returns: An NSAttributedString with `phrase` localized and styled appropriately.
     
     */
    func setAttributedButtonTitle(phrase: String, button: InsetButton, localizedStringFormat: String) {
        
        let attributedString = getAttributedButtonTitle(phrase: phrase,
                                                        localizedStringFormat: localizedStringFormat)
        
        button.setAttributedTitle(attributedString, for: .normal)
    }

    func getAttributedButtonTitle(phrase: String,
                                  localizedStringFormat: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: localizedStringFormat, attributes: [.foregroundColor: UIConstants.Photon.Grey10])
        let phraseString = NSAttributedString(string: phrase, attributes: [.font: UIConstants.fonts.copyButtonQuery,
                                                                           .foregroundColor: UIConstants.Photon.Grey10])
        
        guard let range = attributedString.string.range(of: "%@") else { return phraseString }
        
        let replaceRange = NSRange(range, in: attributedString.string)
        attributedString.replaceCharacters(in: replaceRange, with: phraseString)
        
        return attributedString
    }
    
    func setSearchQuery(queryArray: [String], animated: Bool, hideFindInPage: Bool) {
        searchQueryArray = queryArray
        let oldMax = searchSuggestionsMaxIndex
        searchSuggestionsMaxIndex = min(queryArray.count - 1,maxNumberSuggestions)

        //If search suggestions is turned off, check for empty text string.
        if searchSuggestionsMaxIndex == 0 && queryArray[0] == "" {
            searchSuggestionsMaxIndex = -1
        }

        var showCopyButton = false

        correctNumberOfSearchButtons(by: searchSuggestionsMaxIndex - oldMax)
        let willHide = hideFindInPage || searchSuggestionsMaxIndex < 0
        if findInPageButton.isHidden != willHide{
            adjustForFindInPage(hidden: willHide)
        }
        UIPasteboard.general.urlAsync() { handoffUrl in
            DispatchQueue.main.async {
                if let url = handoffUrl, url.isWebPage() {
                    let attributedTitle = NSMutableAttributedString(string: UIConstants.strings.copiedLink, attributes: [.foregroundColor : UIConstants.Photon.Grey10])
                    let attributedCopiedUrl = NSMutableAttributedString(string: url.absoluteString, attributes: [.font: UIConstants.fonts.copyButtonQuery, .foregroundColor : UIConstants.Photon.Grey10])
                    attributedTitle.append(attributedCopiedUrl)
                    self.copyButton.setAttributedTitle(attributedTitle, for: .normal)
                    showCopyButton = url.isWebPage()
                }
                let emptyArray = self.searchSuggestionsMaxIndex < 0
                let duration = animated ? UIConstants.layout.searchButtonAnimationDuration : 0
                let shouldHideSearchSuggestionsPrompt = emptyArray ||
                    UserDefaults.standard.bool(forKey: SearchSuggestionsPromptView.respondedToSearchSuggestionsPrompt)
                self.displaySearchSuggestionsPrompt(hide: shouldHideSearchSuggestionsPrompt, duration: duration)
                
                if !emptyArray {
                    for index in 0...self.searchSuggestionsMaxIndex {
                        self.setAttributedButtonTitle(phrase: self.searchQueryArray[index], button: self.searchButtonGroup[index], localizedStringFormat: UIConstants.strings.searchButton)
                    }
                    self.setAttributedButtonTitle(phrase: self.searchQueryArray[0], button: self.findInPageButton, localizedStringFormat: UIConstants.strings.findInPageButton)
                }
                if emptyArray != self.findInPageButton.isHidden {
                    self.topBorder.animateHidden(emptyArray, duration: duration)
                    self.findInPageButton.animateHidden(emptyArray || hideFindInPage, duration: duration, completion: {
                        if emptyArray {
                            self.remakeConstraintsAfterHidingButtons(.topBorder, .findInPage)
                        } else {
                            if hideFindInPage {
                                self.remakeConstraintsAfterRevealingButtons(.topBorder)
                                self.remakeConstraintsAfterHidingButtons(.findInPage)
                            } else {
                                self.remakeConstraintsAfterRevealingButtons(.topBorder, .findInPage)
                            }
                        }
                    })
                }
                self.updateCopyConstraint(showCopyButton: showCopyButton)
            }
        }
    }

    fileprivate func updateCopyConstraint(showCopyButton: Bool) {
        if showCopyButton && copyButton.isHidden == true {
            copyButton.isHidden = false
            copyButton.snp.remakeConstraints { make in
                make.height.equalTo(buttonHeight)
            }
            self.remakeConstraintsAfterRevealingButtons(.copyButton)
        } else if !showCopyButton && copyButton.isHidden == false {
            copyButton.isHidden = true
            copyButton.snp.remakeConstraints { make in
                make.height.equalTo(0)
            }
            self.remakeConstraintsAfterHidingButtons(.copyButton)
        }
    }

    @objc private func didPressSearch(sender: IndexedInsetButton ) {
        delegate?.overlayView(self, didSearchForQuery: searchQueryArray[sender.getIndex()])
    }
    @objc private func didPressCopy() {
        delegate?.overlayView(self, didSubmitText: UIPasteboard.general.string!)
    }
    @objc private func didPressFindOnPage() {
        delegate?.overlayView(self, didSearchOnPage: searchQueryArray[0])
    }
    @objc private func didPressSettings() {
        delegate?.overlayViewDidPressSettings(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.overlayViewDidTouchEmptyArea(self)
    }

    func dismiss() {
        setSearchQuery(queryArray: [], animated: false, hideFindInPage: true)
        self.isUserInteractionEnabled = false
        updateCopyConstraint(showCopyButton: false)
        animateHidden(true, duration: UIConstants.layout.overlayAnimationDuration) {
            self.isUserInteractionEnabled = true
        }
    }

    func present() {
        setSearchQuery(queryArray: [], animated: false, hideFindInPage: true)
        self.isUserInteractionEnabled = false
        updateCopyConstraint(showCopyButton: true)
        animateHidden(false, duration: UIConstants.layout.overlayAnimationDuration) {
            self.isUserInteractionEnabled = true
        }
    }
    
    func setSearchSuggestionsPromptViewDelegate(delegate: SearchSuggestionsPromptViewDelegate) {
        searchSuggestionsPrompt.delegate = delegate
    }
    
    func displaySearchSuggestionsPrompt(hide: Bool, duration: TimeInterval = 0) {
        topBorder.backgroundColor = hide ? UIConstants.Photon.Grey90.withAlphaComponent(0.4) : UIColor(rgb: 0x42455A)
        if hide && !searchSuggestionsPrompt.isHidden {
            /*self.searchSuggestionsPrompt.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }*/
            searchSuggestionsPrompt.animateHidden(true, duration: duration, completion: {
                self.remakeConstraintsAfterHidingButtons(.searchPrompt)
            })
        } else if !hide && searchSuggestionsPrompt.isHidden {
            searchSuggestionsPrompt.animateHidden(false, duration: duration, completion: {
                self.remakeConstraintsAfterRevealingButtons(.searchPrompt)
            })
        }
        
    }
}
extension URL {
    public func isWebPage() -> Bool {
        let schemes = ["http", "https"]
        if let scheme = scheme, schemes.contains(scheme) {
            return true
        }
        return false
    }
}

extension OverlayView: KeyboardHelperDelegate {
    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState) {}
    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState) {}
    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState) {}
    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardDidHideWithState state: KeyboardState) {}
}

extension UIPasteboard {
    
    //
    // As of iOS 11: macOS/iOS's Universal Clipboard feature causes UIPasteboard to block.
    //
    // (Known) Apple Radars that have been filed:
    //
    //  http://www.openradar.me/28787338
    //  http://www.openradar.me/28774309
    //
    // Discussion on Twitter:
    //
    //  https://twitter.com/steipete/status/787985965432369152
    //
    //  To workaround this, urlAsync(callback:) makes a call of UIPasteboard.general on
    //  an async dispatch queue, calling the completion block when done.
    //
    func urlAsync(callback: @escaping (URL?) -> Void) {
        DispatchQueue.global().async {
            let url = URL(string: UIPasteboard.general.string ?? "")
            callback(url)
        }
    }
}
