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

class OverlayView: UIView {
    weak var delegate: OverlayViewDelegate?
    private var searchButtonGroup = [IndexedInsetButton]()
    private var searchSuggestionsMaxIndex : Int = 0
    private var presented = false
    private var searchQueryArray : [String] = []
    private let copyButton = UIButton()
    private let findInPageButton = InsetButton()
    private var findInPageHidden = false
    private let topBorder = UIView()
    public var currentURL = ""

    init() {
        super.init(frame: CGRect.zero)
        KeyboardHelper.defaultHelper.addDelegate(delegate: self)

        let padding = UIConstants.layout.searchButtonInset
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

        findInPageButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        findInPageButton.isHidden = false
        findInPageHidden = false
        correctNumberOfButtons()

        topBorder.isHidden = true
        topBorder.alpha = 0
        topBorder.backgroundColor = UIConstants.Photon.Grey90.withAlphaComponent(0.4)
        addSubview(topBorder)

        topBorder.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(findInPageButton.snp.top)
            make.height.equalTo(1)
        }

        self.searchButtonGroup[0].snp.makeConstraints { make in
            make.top.equalTo(findInPageButton.snp.bottom)
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
        }

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

        copyButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func correctNumberOfButtons() {
        if searchSuggestionsMaxIndex >= searchButtonGroup.count{
            for i in searchButtonGroup.count...searchSuggestionsMaxIndex {
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

                self.searchButtonGroup[i].snp.makeConstraints { make in
                    if i > 0 {
                        make.top.equalTo(searchButtonGroup[i - 1].snp.bottom)
                    } else {
                        make.top.equalTo(findInPageButton.snp.bottom)
                    }
                    make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    make.height.equalTo(56)
                }
            }
        } else if searchSuggestionsMaxIndex < searchButtonGroup.count - 1 {
            for index in stride(from: searchButtonGroup.count - 1, to: searchSuggestionsMaxIndex, by: -1) {
                searchButtonGroup[index].removeFromSuperview()
                searchButtonGroup.remove(at: index)
                if index == 0 {
                    findInPageButton.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                    findInPageHidden = true
                    findInPageButton.isHidden = true
                }
            }
        }
    }

    func adjustForFindInPage(hidden:Bool){
        if hidden == findInPageHidden { return }
        findInPageHidden = hidden
        findInPageButton.isHidden = hidden
        if hidden {
            findInPageButton.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        } else {
            findInPageButton.snp.updateConstraints { (make) in
                make.height.equalTo(56)
            }
        }
        if searchSuggestionsMaxIndex >= 0 {
            for i in 0...searchSuggestionsMaxIndex {
                self.searchButtonGroup[i].snp.updateConstraints { (make) in
                    if i > 0 {
                        make.top.equalTo(searchButtonGroup[i - 1].snp.bottom)
                    } else {
                        make.top.equalTo(findInPageButton.snp.bottom)
                    }
                }
            }
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
    
    func setAttributedButtonTitle(phrase: String, button: InsetButton, localizedStringFormat: String) {
        
        let attributedString = getAttributedButtonTitle(phrase: phrase,
                                                        localizedStringFormat: localizedStringFormat)
        
        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setSearchQuery(queryArray: [String], animated: Bool, hideFindInPage: Bool) {
        searchQueryArray = queryArray
        searchSuggestionsMaxIndex = min(queryArray.count - 1,4)
        //If search suggestions is turned off, check for empty text string.
        if searchSuggestionsMaxIndex == 0 && queryArray[0] == "" {
            searchSuggestionsMaxIndex = -1
        }
        var showCopyButton = false
        correctNumberOfButtons()
        adjustForFindInPage(hidden:hideFindInPage)
        UIPasteboard.general.urlAsync() { handoffUrl in
            DispatchQueue.main.async {
                if let url = handoffUrl, url.isWebPage() {
                    let attributedTitle = NSMutableAttributedString(string: UIConstants.strings.copiedLink, attributes: [.foregroundColor : UIConstants.Photon.Grey10])
                    let attributedCopiedUrl = NSMutableAttributedString(string: url.absoluteString, attributes: [.font: UIConstants.fonts.copyButtonQuery, .foregroundColor : UIConstants.Photon.Grey10])
                    attributedTitle.append(attributedCopiedUrl)
                    self.copyButton.setAttributedTitle(attributedTitle, for: .normal)
                    showCopyButton = url.isWebPage()
                }
                if self.searchSuggestionsMaxIndex >= 0 {
                    let duration = animated ? UIConstants.layout.searchButtonAnimationDuration : 0
                    self.topBorder.animateHidden(queryArray.isEmpty, duration: duration)
                    self.searchButtonGroup.forEach { searchButton in
                        searchButton.animateHidden(queryArray.isEmpty, duration: duration)
                    }
                    self.findInPageButton.animateHidden(queryArray.isEmpty || hideFindInPage, duration: duration, completion: {
                        self.updateCopyConstraint(showCopyButton: showCopyButton)
                    })

                    for index in 0...self.searchSuggestionsMaxIndex {
                        self.setAttributedButtonTitle(phrase: self.searchQueryArray[index], button: self.searchButtonGroup[index], localizedStringFormat: UIConstants.strings.searchButton)
                    }
                    self.setAttributedButtonTitle(phrase: self.searchQueryArray[0], button: self.findInPageButton, localizedStringFormat: UIConstants.strings.findInPageButton)
                } else {
                    self.updateCopyConstraint(showCopyButton: showCopyButton)
                }
            }
        }
    }

    fileprivate func updateCopyConstraint(showCopyButton: Bool) {
        if showCopyButton {
            copyButton.isHidden = false
            if searchButtonGroup[0].isHidden || searchQueryArray.isEmpty {
                copyButton.snp.remakeConstraints { make in
                    make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
                    make.height.equalTo(56)
                }
            } else if searchSuggestionsMaxIndex > 0 {
                copyButton.snp.remakeConstraints { make in
                    make.leading.trailing.equalTo(safeAreaLayoutGuide)
                    make.top.equalTo(searchButtonGroup[searchSuggestionsMaxIndex].snp.bottom)
                    make.height.equalTo(56)
                }
            } else {
                copyButton.snp.remakeConstraints { make in
                    make.leading.top.trailing.equalTo(safeAreaLayoutGuide)
                    make.height.equalTo(56)
                }
            }
        } else {
            copyButton.isHidden = true
        }
        layoutIfNeeded()
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
        copyButton.isHidden = true
        animateHidden(true, duration: UIConstants.layout.overlayAnimationDuration) {
            self.isUserInteractionEnabled = true
        }
    }

    func present() {
        setSearchQuery(queryArray: [], animated: false, hideFindInPage: true)
        self.isUserInteractionEnabled = false
        copyButton.isHidden = false
        animateHidden(false, duration: UIConstants.layout.overlayAnimationDuration) {
            self.isUserInteractionEnabled = true
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
