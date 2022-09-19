/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Combine
import UIHelpers

public class URLBar: UIView {
    public weak var delegate: URLBarDelegate?
    public var shouldPresent = false

    // MARK: - UI Components

    public var contextMenuButtonAnchor: UIView { contextMenuButton }
    public var deleteButtonAnchor: UIView { deleteButton }
    public var shieldIconButtonAnchor: UIView { shieldIconButton }
    public var urlTextFieldAnchor: UIView { urlTextField }

    fileprivate var draggableUrlTextView: UIView { urlTextField }

    lazy var urlBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .locationBar
        view.layer.cornerRadius = .urlBarCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var urlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var urlTextField: URLTextField = {
        let textField = URLTextField()

        // UITextField doesn't allow customization of the clear button, so we create
        // our own so we can use it as the rightView.
        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: .urlBarClearButtonWidth, height: .urlBarClearButtonHeight))
        clearButton.isHidden = true
        clearButton.setImage(.clear, for: .normal)
        clearButton.addTarget(self, action: #selector(didPressClear), for: .touchUpInside)
        textField.font = .body15
        textField.tintColor = .primaryText
        textField.textColor = .primaryText
        textField.keyboardType = .webSearch
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
//        textField.clearButtonMode = .whileEditing
        textField.rightView = clearButton
        textField.rightViewMode = .whileEditing
        textField.setContentHuggingPriority(UILayoutPriority(rawValue: .urlBarLayoutPriorityRawValue), for: .vertical)
        textField.autocompleteDelegate = self
        textField.accessibilityIdentifier = "URLBar.urlText"
        textField.placeholder = viewModel.strings.urlTextPlaceholder
//        if let clearButton = textField.value(forKeyPath: "_clearButton") as? UIButton {
//            clearButton.setImage(#imageLiteral(resourceName: "icon_clear"), for: .normal)
//        }
        return textField
    }()

    lazy var truncatedUrlText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.alpha = 0
        textView.isUserInteractionEnabled = false
        textView.font = .footnote12
        textView.tintColor = .primaryText
        textView.textColor = .primaryText
        textView.backgroundColor = UIColor.clear
        textView.contentMode = .bottom
        textView.setContentHuggingPriority(UILayoutPriority(rawValue: .urlBarLayoutPriorityRawValue), for: .vertical)
        textView.isScrollEnabled = false
        textView.accessibilityIdentifier = "Collapsed.truncatedUrlText"
        return textView
    }()

    let progressBar: GradientProgressBar = {
        let progressBar = GradientProgressBar(progressViewStyle: .bar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.isHidden = true
        progressBar.alpha = 0
        return progressBar
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.alpha = 0
        button.setImage(.cancel, for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        button.accessibilityIdentifier = "URLBar.cancelButton"
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .urlBarHeight),
            button.heightAnchor.constraint(equalToConstant: .urlBarHeight)
        ])
        return button
    }()

    let urlBarBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryButton
        view.layer.cornerRadius = .urlBarCornerRadius
        view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: .urlBarLayoutPriorityRawValue), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(rawValue: .urlBarLayoutPriorityRawValue), for: .horizontal)
        return view
    }()

    lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.backActive, for: .normal)
        button.accessibilityLabel = viewModel.strings.browserBack
        button.isEnabled = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.forwardActive, for: .normal)
        button.accessibilityLabel = viewModel.strings.browserForward
        button.isEnabled = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    lazy var stopReloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.refreshMenu, for: .normal)
        button.accessibilityIdentifier = "BrowserToolset.stopReloadButton"
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.delete, for: .normal)
        button.accessibilityIdentifier = "URLBar.deleteButton"
        button.isEnabled = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    lazy var contextMenuButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.hamburgerMenu, for: .normal)
        button.tintColor = .primaryText
        if #available(iOS 14.0, *) {
            button.showsMenuAsPrimaryAction = true
            button.menu = UIMenu(children: [])
        }
        button.accessibilityLabel = viewModel.strings.browserSettings
        button.accessibilityIdentifier = "HomeView.settingsButton"
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight - 8),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    fileprivate var cancellables = Set<AnyCancellable>()

    lazy var shieldIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.setImage(.trackingProtectionOn, for: .normal)
        button.contentMode = .center
        button.accessibilityIdentifier = "URLBar.trackingProtectionIcon"
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    public override var canBecomeFirstResponder: Bool { true }

    fileprivate var viewModel: URLBarViewModel

    fileprivate func bindButtonActions() {
        shieldIconButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.shieldIconButtonTap)
            }
            .store(in: &cancellables)

        backButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.backButtonTap)
            }
            .store(in: &cancellables)

        forwardButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.forwardButtonTap)
            }
            .store(in: &cancellables)

        stopReloadButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                if viewModel.isLoading {
                    self.viewModel
                        .viewActionSubject
                        .send(.stopButtonTap)
                } else {
                    self.viewModel
                        .viewActionSubject
                        .send(.reloadButtonTap)
                }
            }
            .store(in: &cancellables)

        deleteButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.deleteButtonTap)
            }
            .store(in: &cancellables)

        let event: UIControl.Event
        if #available(iOS 14.0, *) {
            event = .menuActionTriggered
        } else {
            event = .touchUpInside
        }
        contextMenuButton.publisher(event: event)
            .sink { [unowned self] _ in
                self.viewModel.viewActionSubject.send(.contextMenuTap(anchor: self.contextMenuButton))
            }
            .store(in: &cancellables)

    }

    fileprivate func bindViewModelEvents() {
        viewModel
            .$connectionState
            .removeDuplicates()
            .map { trackingProtectionStatus -> UIImage in
                switch trackingProtectionStatus {
                case .on: return .trackingProtectionOn
                case .off: return .trackingProtectionOff
                case .connectionNotSecure: return .connectionNotSecure
                }
            }
            .sink(receiveValue: { [shieldIconButton] image in
                UIView.transition(
                    with: shieldIconButton,
                    duration: 0.1,
                    options: .transitionCrossDissolve,
                    animations: {
                        shieldIconButton.setImage(image, for: .normal)
                    })
            })
            .store(in: &cancellables)

        viewModel
            .$canGoBack
            .sink { [backButton] in
                backButton.isEnabled = $0
                backButton.alpha = $0 ? 1 : .browserToolbarDisabledOpacity
            }
            .store(in: &cancellables)

        viewModel
            .$canGoForward
            .sink { [forwardButton] in
                forwardButton.isEnabled = $0
                forwardButton.alpha = $0 ? 1 : .browserToolbarDisabledOpacity
            }
            .store(in: &cancellables)

        viewModel
            .$canDelete
            .sink { [deleteButton] in
                deleteButton.isEnabled = $0
                deleteButton.alpha = $0 ? 1 : .browserToolbarDisabledOpacity
            }
            .store(in: &cancellables)

        viewModel
            .$isLoading
            .sink { [viewModel, stopReloadButton] in
                if $0 {
                    stopReloadButton.setImage(.stopMenu, for: .normal)
                    stopReloadButton.accessibilityLabel = viewModel.strings.browserStop
                } else {
                    stopReloadButton.setImage(.refreshMenu, for: .normal)
                    stopReloadButton.accessibilityLabel = viewModel.strings.browserReload
                }
            }
            .store(in: &cancellables)

        viewModel
            .statePublisher
            .removeDuplicates(by: ==)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                adaptUI(for: $0, orientation: $1)
            }
            .store(in: &cancellables)

        viewModel
            .$selectionState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] selectionState in
                adaptUI(for: selectionState)
                switch selectionState {
                    case .selected:
                        delegate?.urlBarDidFocus(self)

                    case .unselected:
                        delegate?.urlBarDidDismiss(self)
                }
            }
            .store(in: &cancellables)

        viewModel
            .$url
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] url in
                setTextToURL(url: url)
            }
            .store(in: &cancellables)

        viewModel
            .$loadingProgres
            .map(Float.init)
            .filter { 0 <= $0 && $0 <= 1 }
            .sink { [progressBar] in
                progressBar.alpha = 1
                progressBar.isHidden = false
                progressBar.setProgress($0, animated: true)
            }
            .store(in: &cancellables)
    }

    func adaptUI(for selection: URLBarViewModel.Selection) {
        switch selection {
        case .selected:
            cancelButton
                .fadeIn(
                    firstDo: { [stackView, urlStackView, cancelButton] in
                        guard
                            let index = stackView.arrangedSubviews.firstIndex(of: urlStackView)
                        else { return }

                        stackView.insertArrangedSubview(cancelButton, at: index)
                    }
                )

            shieldIconButton.fadeOut()
            self.urlTextField.isUserInteractionEnabled = true
            self.urlTextField.becomeFirstResponder()
            self.highlightText(self.urlTextField)

        case .unselected:
            _ = urlTextField.resignFirstResponder()
            urlTextField.isUserInteractionEnabled = true
            cancelButton.animateFadeOutFromSuperview()
            shieldIconButton.fadeIn()
        }
    }

    func adaptUI(for browsingState: URLBarViewModel.BrowsingState, orientation: URLBarViewModel.Layout) {
        switch (browsingState, orientation) {
            case (.home, _):
                stopReloadButton.animateFadeOutFromSuperview()
                stackView.addArrangedSubview(contextMenuButton)
                contextMenuButton.fadeIn()
                forwardButton.animateFadeOutFromSuperview()
                backButton.animateFadeOutFromSuperview()
                deleteButton.animateFadeOutFromSuperview()

            case (.browsing, .compact):
                stopReloadButton
                    .fadeIn(
                        firstDo: { [urlStackView, stopReloadButton] in
                            urlStackView.appendArrangedSubview(stopReloadButton)
                        })

                contextMenuButton.animateFadeOutFromSuperview()
                forwardButton.animateFadeOutFromSuperview()
                backButton.animateFadeOutFromSuperview()
                deleteButton.animateFadeOutFromSuperview()

            case (.browsing, .large):
                forwardButton
                    .fadeIn(
                        firstDo: { [stackView, forwardButton] in
                            stackView.prependArrangedSubview(forwardButton)
                        }
                    )
                backButton
                    .fadeIn(
                        firstDo: { [stackView, backButton] in
                            stackView.prependArrangedSubview(backButton)
                        }
                    )

                contextMenuButton
                    .fadeIn(
                        firstDo: { [deleteButton, contextMenuButton, stackView] in
                            deleteButton
                                .fadeIn(firstDo: { stackView.appendArrangedSubview(deleteButton) })
                            stackView.appendArrangedSubview(contextMenuButton)
                        },
                        thenDo: { [stopReloadButton, urlStackView] in
                            stopReloadButton
                                .fadeIn(firstDo: {urlStackView.appendArrangedSubview(stopReloadButton) })
                        })
        }
    }

    public init(viewModel: URLBarViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        bindButtonActions()
        bindViewModelEvents()

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(sender:)))
        singleTap.numberOfTapsRequired = 1
        truncatedUrlText.addGestureRecognizer(singleTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(displayURLContextMenu))
        urlStackView.addGestureRecognizer(longPress)

        let dragInteraction = UIDragInteraction(delegate: self)
        urlStackView.addInteraction(dragInteraction)

        setupLayout()
    }

    func setupLayout() {
        addSubview(urlBarBackgroundView)
        urlStackView.addArrangedSubview(shieldIconButton)
        urlStackView.addArrangedSubview(urlTextField)
        stackView.addArrangedSubview(urlStackView)
        addSubview(stackView)
        addSubview(truncatedUrlText)
        addSubview(progressBar)

        NSLayoutConstraint.activate([
            truncatedUrlText.centerXAnchor.constraint(equalTo: centerXAnchor),
            truncatedUrlText.heightAnchor.constraint(equalToConstant: .collapsedUrlBarHeight),
            truncatedUrlText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            urlBarBackgroundView.topAnchor.constraint(equalTo: urlStackView.topAnchor),
            urlBarBackgroundView.leadingAnchor.constraint(equalTo: urlStackView.leadingAnchor),
            urlBarBackgroundView.trailingAnchor.constraint(equalTo: urlStackView.trailingAnchor),
            urlBarBackgroundView.bottomAnchor.constraint(equalTo: urlStackView.bottomAnchor),

            stackView.heightAnchor.constraint(equalToConstant: .urlBarHeight),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),

            progressBar.heightAnchor.constraint(equalToConstant: .progressBarHeight),
            progressBar.topAnchor.constraint(equalTo: bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func displayClearButton(shouldDisplay: Bool, animated: Bool = true) {
        // Prevent the rightView's position from being animated
        urlTextField.rightView?.layer.removeAllAnimations()
        urlTextField.rightView?.animateHidden(!shouldDisplay, duration: animated ? .urlBarTransitionAnimationDuration : 0)
    }

    public func copyToClipboard() {
        UIPasteboard.general.string = viewModel.url?.absoluteString ?? ""
    }

    fileprivate func pasteAndGo(clipboardString: String) {
        delegate?.urlBarDidActivate(self)
        delegate?.urlBar(self, didSubmitText: clipboardString)
        self.viewModel
            .viewActionSubject
            .send(.pasteAndGo)
    }

    @objc fileprivate func copyLink() {
        self.viewModel
            .url
            .map(\.absoluteString)
            .map { UIPasteboard.general.string = $0 }
    }

    @objc fileprivate func pasteAndGoFromContextMenu() {
        guard let clipboardString = UIPasteboard.general.string else { return }
        pasteAndGo(clipboardString: clipboardString)
    }

    // Adds Menu Item
    fileprivate func addCustomMenu() {
        var items = [UIMenuItem]()

        if urlTextField.text != nil, urlTextField.text?.isEmpty == false {
            let copyItem = UIMenuItem(title: viewModel.strings.copyMenuButton, action: #selector(copyLink))
            items.append(copyItem)
        }

        if UIPasteboard.general.hasStrings {
            let lookupMenu = UIMenuItem(title: viewModel.strings.urlPasteAndGo, action: #selector(pasteAndGoFromContextMenu))
            items.append(lookupMenu)
        }

        UIMenuController.shared.menuItems = items
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        addCustomMenu()
        return super.canPerformAction(action, withSender: sender)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Since the URL text field is smaller and centered on iPads, make sure
        // that touching the surrounding area will trigger editing.
        if urlTextField.isUserInteractionEnabled,
           let touch = touches.first {
            let point = touch.location(in: urlBarBorderView)
            if urlBarBorderView.bounds.contains(point) {
                urlTextField.becomeFirstResponder()
                return
            }
        }
        super.touchesEnded(touches, with: event)
    }

    public func ensureBrowsingMode() {
        shouldPresent = false
        viewModel.browsingState = .browsing
    }

    /* This separate @objc function is necessary as selector methods pass sender by default. Calling
     dismiss() directly from a selector would pass the sender as "completion" which results in a crash. */
    @objc fileprivate func cancelPressed() {
        viewModel.selectionState = .unselected
    }

    public func dismiss(completion: (() -> Void)? = nil) {
        guard viewModel.selectionState.isSelecting else {
            completion?()
            return
        }

        viewModel.selectionState = .unselected
        completion?()
    }

    @objc fileprivate func didSingleTap(sender: UITapGestureRecognizer) {
        delegate?.urlBarDidPressScrollTop(self, tap: sender)
    }

    // MARK: - URL

    @objc fileprivate func didPressClear() {
        urlTextField.text = nil
        viewModel.userInputText = nil
        displayClearButton(shouldDisplay: false)
        delegate?.urlBar(self, didEnterText: "")
    }

    public func fillUrlBar(text: String) {
        urlTextField.text = text
    }

    fileprivate func setTextToURL(url: URL?, displayFullUrl: Bool = false) {
        guard let url = url else {
            urlTextField.text = nil
            viewModel.userInputText = nil
            return
        }

        // Strip the username/password to prevent domain spoofing.
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.user = nil
        components?.password = nil
        let fullUrl = components?.url?.absoluteString
        let truncatedURL = components?.host
        let displayText = truncatedURL
        urlTextField.text = displayFullUrl ? fullUrl : displayText
        truncatedUrlText.text = truncatedURL
    }

    @objc fileprivate func displayURLContextMenu(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.urlBarDidLongPress(self)
            self.isUserInteractionEnabled = true
            self.becomeFirstResponder()
            UIMenuController.shared.showMenu(from: self, rect: self.bounds)
        }
    }

    fileprivate func deactivate() {
        urlTextField.text = nil
        displayClearButton(shouldDisplay: false)

        UIView.animate(withDuration: .urlBarTransitionAnimationDuration, animations: {
            self.layoutIfNeeded()
        })

        delegate?.urlBarDidDeactivate(self)
    }

    func highlightText(_ textField: UITextField) {
        guard textField.text != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            textField.selectAll(nil)
        }
    }

    public enum CollapsedState: Equatable {
        case extended
        case intermediate(expandAlpha: CGFloat, collapseAlpha: CGFloat)
        case collapsed
    }

    public var collapsedState: CollapsedState = .extended {
        didSet {
            DispatchQueue.main.async {
                self.updateCollapsedState()
            }
        }
    }

    public func updateCollapsedState() {
        switch collapsedState {
        case .extended:
            collapseUrlBar(expandAlpha: 1, collapseAlpha: 0)
        case .intermediate(expandAlpha: let expandAlpha, collapseAlpha: let collapseAlpha):
            collapseUrlBar(expandAlpha: expandAlpha, collapseAlpha: collapseAlpha)
        case .collapsed:
            collapseUrlBar(expandAlpha: 0, collapseAlpha: 1)
        }
    }

    fileprivate func collapseUrlBar(expandAlpha: CGFloat, collapseAlpha: CGFloat) {
        urlBarBorderView.alpha = expandAlpha
        urlBarBackgroundView.alpha = expandAlpha
        truncatedUrlText.alpha = collapseAlpha
        backButton.alpha = shouldShowToolset ? expandAlpha : 0
        forwardButton.alpha = shouldShowToolset ? expandAlpha : 0
        deleteButton.alpha = shouldShowToolset ? expandAlpha : 0
        contextMenuButton.alpha = expandAlpha
        stackView.alpha = expandAlpha

        if viewModel.selectionState.isSelecting {
            shieldIconButton.alpha = collapseAlpha
        } else {
            shieldIconButton.alpha = expandAlpha
        }

        self.layoutIfNeeded()
    }

    public var shouldShowToolset: Bool = false

}

extension URLBar: AutocompleteTextFieldDelegate {
    func autocompleteTextFieldShouldClear(_ autocompleteTextField: AutocompleteTextField) -> Bool { return false }

    func autocompleteTextFieldDidCancel(_ autocompleteTextField: AutocompleteTextField) { }

    func autocompletePasteAndGo(_ autocompleteTextField: AutocompleteTextField) { }

    func autocompleteTextFieldShouldEndEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool { return true }

    func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool {

        setTextToURL(url: viewModel.url, displayFullUrl: true)

        if !viewModel.selectionState.isSelecting {
            viewModel.selectionState = .selected
            delegate?.urlBarDidActivate(self)
        }

        // When text.characters.count == 0, it is the HomeView
        if let text = autocompleteTextField.text, !viewModel.selectionState.isSelecting, text.count == 0 {
            shouldPresent = true
        }

        return true
    }

    func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        // If the new search string is not longer than the previous
        // we don't need to find an autocomplete suggestion.
        viewModel.userInputText = nil
        delegate?.urlBar(self, didSubmitText: autocompleteTextField.text ?? "")
        return true
    }

    func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didEnterText text: String) {
        if let oldValue = viewModel.userInputText, oldValue.count < text.count {
            let completion = viewModel.domainCompletion.autocompleteTextFieldCompletionSource(autocompleteTextField, forText: text)
            autocompleteTextField.setAutocompleteSuggestion(completion)
        }

        viewModel.userInputText = text

        if !text.isEmpty {
            displayClearButton(shouldDisplay: true, animated: true)
        }

        autocompleteTextField.rightView?.isHidden = text.isEmpty

        if !viewModel.selectionState.isSelecting && shouldPresent {
            viewModel.selectionState = .selected
            delegate?.urlBarDidActivate(self)
        }
        delegate?.urlBar(self, didEnterText: text)
    }
}

extension URLBar: UIDragInteractionDelegate {
    public func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let url = viewModel.url, let itemProvider = NSItemProvider(contentsOf: url) else { return [] }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        self.viewModel
            .viewActionSubject
            .send(.dragInteractionStarted)
        return [dragItem]
    }

    public func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        let params = UIDragPreviewParameters()
        params.backgroundColor = UIColor.clear
        return UITargetedDragPreview(view: draggableUrlTextView, parameters: params)
    }

    public func dragInteraction(_ interaction: UIDragInteraction, sessionDidMove session: UIDragSession) {
        for item in session.items {
            item.previewProvider = {
                guard let url = self.viewModel.url else {
                    return UIDragPreview(view: UIView())
                }
                return UIDragPreview(for: url)
            }
        }
    }
}
