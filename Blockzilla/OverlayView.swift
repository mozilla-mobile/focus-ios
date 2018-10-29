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
    func setIndex(_ i:Int) {
        index = i
    }
    func getIndex() -> Int {
        return index
    }
}

/*Int value indicates vertical priority.
  If all are visible, topBorder will be at the top, and searchGroup will be at the bottom.
*/
enum ButtonViews: Int {
    case topBorder = 0
    case searchPrompt = 1
    case copyButton = 2
    case findInPage = 3
    case searchGroup = 4
}

class OverlayView: UIView {
    weak var delegate: OverlayViewDelegate?
    private let asyncDispatchGroup = DispatchGroup()
    private var searchButtonGroup = [IndexedInsetButton]()
    private var needToRemakeConstraints : Bool
    private var searchSuggestionsMaxIndex : Int
    private let maxNumberSuggestions = 4
    private var searchQueryArray : [String] = []
    private let copyButton = UIButton()
    private let findInPageButton = InsetButton()
    private let searchSuggestionsPrompt = SearchSuggestionsPromptView()
    private let topBorder = UIView()
    private var buttonViewsVisible : [Bool] = Array(repeating: true, count: 5)
    public var currentURL = ""

    init() {
        searchSuggestionsMaxIndex = Settings.getToggle(.enableSearchSuggestions) ? maxNumberSuggestions : 0
        needToRemakeConstraints = true
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

        // Warm-up constraints.
        moveTheButtons()
        setSearchQuery(queryArray: [], animated: false, hideFindInPage: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeFindInPageButton(withPadding padding:CGFloat) {
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
    
    private func makeCopyButton(withPadding padding:CGFloat) {
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

    private func makeSearchButton(atIndex i: Int) {
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

    private func updateNumberOfSearchButtonsDisplayed(amount numberRowsToAdjust: Int) {
        // Create more buttons if just turned on SearchSuggestions
        if maxNumberSuggestions >= searchButtonGroup.count {
            for i in searchButtonGroup.count...maxNumberSuggestions {
                makeSearchButton(atIndex: i)
            }
        }
        //Hide Buttons if too many showing
        if numberRowsToAdjust < 0 {
            for i in numberRowsToAdjust ... -1 {
                let index = searchSuggestionsMaxIndex - i
                searchButtonGroup[index].animateHidden(true, duration: 0)
                searchButtonGroup[index].snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
                if index == 0 {
                    hideButtons(.searchGroup)
                }
            }
        }
        //Show buttons if some currently hidden
        else if numberRowsToAdjust > 0 {
            for i in 0 ... numberRowsToAdjust - 1 {
                let index = searchSuggestionsMaxIndex - numberRowsToAdjust + 1 + i
                searchButtonGroup[index].animateHidden(false, duration: 0)
                if index == 0 {
                    revealButtons(.searchGroup)
                    moveTheButtons()
                } else {
                    searchButtonGroup[index].snp.remakeConstraints { (make) in
                        make.height.equalTo(UIConstants.layout.overlayButtonSize)
                        make.top.equalTo(searchButtonGroup[index-1].snp.bottom)
                        make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    }
                }
            }
        }
    }

    private func getButton(_ button:ButtonViews) -> UIView {
        switch button {
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

    private func hideButtons(_ buttons: ButtonViews ...) {
        for button in buttons {
            if buttonViewsVisible[button.rawValue] {
                buttonViewsVisible[button.rawValue] = false
                let theButton = getButton(button)
                if button != ButtonViews.searchPrompt {
                    theButton.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                }
                needToRemakeConstraints = true
            }
        }
    }

    private func revealButtons(_ buttons: ButtonViews ...) {
        for button in buttons {
            if !buttonViewsVisible[button.rawValue] {
                buttonViewsVisible[button.rawValue] = true
                needToRemakeConstraints = true
            }
        }
    }

    private func moveTheButtons() {
        if !needToRemakeConstraints { return }
        var previousIndex : Int?
        for i in 0...buttonViewsVisible.count - 1 {
            //If view isn't visible, skip it.
            if !buttonViewsVisible[i] {continue}
            var height = UIConstants.layout.overlayButtonSize
            let buttonView = ButtonViews(rawValue: i)!
            let theButton = getButton(buttonView)
            if ButtonViews(rawValue: i) == .topBorder {
                height = 1
            }
            if let topIndex = previousIndex {
                let topButton = getButton(ButtonViews(rawValue: topIndex)!)
                theButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(topButton.snp.bottom)
                    make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    if buttonView != .searchPrompt {
                        make.height.equalTo(height)
                    }
                }
                if buttonView == .searchGroup && searchSuggestionsMaxIndex > 0 {
                    for index in 1...searchSuggestionsMaxIndex {
                        searchButtonGroup[index].snp.remakeConstraints { (make) in
                            make.top.equalTo(searchButtonGroup[index-1].snp.bottom)
                            make.leading.trailing.equalTo(safeAreaLayoutGuide)
                            make.height.equalTo(UIConstants.layout.overlayButtonSize)
                        }
                    }
                }
            } else {
                theButton.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    make.top.equalTo(self.snp.top)
                    if buttonView != .searchPrompt {
                        make.height.equalTo(height)
                    }
                }
            }
            previousIndex = i
        }
        needToRemakeConstraints = false
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
        asyncDispatchGroup.enter()
        searchQueryArray = queryArray
        let oldMax = searchSuggestionsMaxIndex
        searchSuggestionsMaxIndex = min(queryArray.count - 1,maxNumberSuggestions)

        //If search suggestions is turned off, check for empty text string.
        if searchSuggestionsMaxIndex == 0 && queryArray[0] == "" {
            searchSuggestionsMaxIndex = -1
        }

        updateNumberOfSearchButtonsDisplayed(amount: searchSuggestionsMaxIndex - oldMax)
        let willHide = hideFindInPage || searchSuggestionsMaxIndex < 0
        if findInPageButton.isHidden != willHide {
             willHide ? hideButtons(.findInPage) : revealButtons(.findInPage)
        }
        UIPasteboard.general.urlAsync() { handoffUrl in
            self.asyncDispatchGroup.enter()
            DispatchQueue.main.async {
                if let url = handoffUrl, url.isWebPage() {
                    let attributedTitle = NSMutableAttributedString(string: UIConstants.strings.copiedLink, attributes: [.foregroundColor : UIConstants.Photon.Grey10])
                    let attributedCopiedUrl = NSMutableAttributedString(string: url.absoluteString, attributes: [.font: UIConstants.fonts.copyButtonQuery, .foregroundColor : UIConstants.Photon.Grey10])
                    attributedTitle.append(attributedCopiedUrl)
                    self.copyButton.setAttributedTitle(attributedTitle, for: .normal)
                    self.updateCopyConstraint(showCopyButton: url.isWebPage())
                }
                let emptyArray = self.searchSuggestionsMaxIndex < 0
                let duration = animated ? UIConstants.layout.searchButtonAnimationDuration : 0
                let shouldHideSearchSuggestionsPrompt = emptyArray ||
                    UserDefaults.standard.bool(forKey: SearchSuggestionsPromptView.respondedToSearchSuggestionsPrompt)
                self.displaySearchSuggestionsPrompt(hide: shouldHideSearchSuggestionsPrompt, duration: duration)
                
                if !emptyArray {
                    self.revealButtons(.topBorder)
                    for index in 0...self.searchSuggestionsMaxIndex {
                        self.setAttributedButtonTitle(phrase: self.searchQueryArray[index], button: self.searchButtonGroup[index], localizedStringFormat: UIConstants.strings.searchButton)
                    }
                    self.setAttributedButtonTitle(phrase: self.searchQueryArray[0], button: self.findInPageButton, localizedStringFormat: UIConstants.strings.findInPageButton)
                }
                if emptyArray != self.findInPageButton.isHidden {
                    self.topBorder.animateHidden(emptyArray, duration: duration)
                    self.findInPageButton.animateHidden(emptyArray || hideFindInPage, duration: duration)
                    if emptyArray || hideFindInPage {
                        self.hideButtons(.topBorder, .findInPage)
                    } else {
                        self.revealButtons(.findInPage)
                    }
                }
                self.asyncDispatchGroup.leave()
            }
            self.asyncDispatchGroup.leave()
        }
        asyncDispatchGroup.notify(queue: .main) {
            self.moveTheButtons()
        }
    }

    fileprivate func updateCopyConstraint(showCopyButton: Bool) {
        if showCopyButton && copyButton.isHidden == true {
            copyButton.isHidden = false
            self.revealButtons(.copyButton)
        } else if !showCopyButton && copyButton.isHidden == false {
            copyButton.isHidden = true
            self.hideButtons(.copyButton)
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
        animateHidden(true, duration: UIConstants.layout.overlayAnimationDuration) {
            self.isUserInteractionEnabled = true
        }
    }

    func present() {
        setSearchQuery(queryArray: [], animated: false, hideFindInPage: true)
        self.isUserInteractionEnabled = false
        animateHidden(false, duration: UIConstants.layout.overlayAnimationDuration) {
            self.isUserInteractionEnabled = true
        }
    }
    
    func setSearchSuggestionsPromptViewDelegate(delegate: SearchSuggestionsPromptViewDelegate) {
        searchSuggestionsPrompt.delegate = delegate
    }
    
    private func displaySearchSuggestionsPrompt(hide: Bool, duration: TimeInterval = 0) {
        topBorder.backgroundColor = hide ? UIConstants.Photon.Grey90.withAlphaComponent(0.4) : UIColor(rgb: 0x42455A)
        if hide && !searchSuggestionsPrompt.isHidden {
            self.hideButtons(.searchPrompt)
            searchSuggestionsPrompt.animateHidden(true, duration: duration)
        } else if !hide && searchSuggestionsPrompt.isHidden {
            self.revealButtons(.searchPrompt)
            searchSuggestionsPrompt.animateHidden(false, duration: duration)
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
