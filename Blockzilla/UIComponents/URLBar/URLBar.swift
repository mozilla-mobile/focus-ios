/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Telemetry
import Glean
import DesignSystem
import Combine
import UIHelpers

public class URLBar: UIView {
    public weak var delegate: URLBarDelegate?

    public var shouldPresent = false
    public var isIPadRegularDimensions = false {
        didSet {
        }
    }

    // MARK: - UI Components

    public var contextMenuButtonAnchor: UIView { contextMenuButton }
    public var deleteButtonAnchor: UIView { deleteButton }
    public var shieldIconButtonAnchor: UIView { shieldIconButton }

    private var draggableUrlTextView: UIView { urlTextField }

    private lazy var urlBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .locationBar
        view.layer.cornerRadius = UIConstants.layout.urlBarCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [urlStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var urlStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                shieldIconButton,
                urlTextField
            ])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var urlTextField: URLTextField = {
        let textField = URLTextField()

        // UITextField doesn't allow customization of the clear button, so we create
        // our own so we can use it as the rightView.
        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIConstants.layout.urlBarClearButtonWidth, height: UIConstants.layout.urlBarClearButtonHeight))
        clearButton.isHidden = true
        clearButton.setImage(#imageLiteral(resourceName: "icon_clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(didPressClear), for: .touchUpInside)

        textField.font = .body15
        textField.tintColor = .primaryText
        textField.textColor = .primaryText
        textField.keyboardType = .webSearch
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.rightView = clearButton
        textField.rightViewMode = .whileEditing
        textField.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .vertical)
        textField.autocompleteDelegate = self
        textField.accessibilityIdentifier = "URLBar.urlText"
        textField.placeholder = UIConstants.strings.urlTextPlaceholder
        return textField
    }()

    private lazy var truncatedUrlText: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.alpha = 0
        textView.isUserInteractionEnabled = false
        textView.font = .footnote12
        textView.tintColor = .primaryText
        textView.textColor = .primaryText
        textView.backgroundColor = UIColor.clear
        textView.contentMode = .bottom
        textView.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .vertical)
        textView.isScrollEnabled = false
        textView.accessibilityIdentifier = "Collapsed.truncatedUrlText"
        return textView
    }()

    private let progressBar: GradientProgressBar = {
        let progressBar = GradientProgressBar(progressViewStyle: .bar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.isHidden = true
        progressBar.alpha = 0
        return progressBar
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.alpha = 0
        button.setImage(#imageLiteral(resourceName: "icon_cancel"), for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        button.accessibilityIdentifier = "URLBar.cancelButton"
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private let urlBarBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryButton
        view.layer.cornerRadius = UIConstants.layout.urlBarCornerRadius
        view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icon_back_active"), for: .normal)
        button.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        button.accessibilityLabel = UIConstants.strings.browserBack
        button.isEnabled = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icon_forward_active"), for: .normal)
        button.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        button.accessibilityLabel = UIConstants.strings.browserForward
        button.isEnabled = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private lazy var stopReloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icon_refresh_menu"), for: .normal)
        button.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        button.accessibilityIdentifier = "BrowserToolset.stopReloadButton"
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icon_delete"), for: .normal)
        button.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        button.accessibilityIdentifier = "URLBar.deleteButton"
        button.isEnabled = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: .barButtonHeight),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private lazy var contextMenuButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icon_hamburger_menu"), for: .normal)
        button.tintColor = .primaryText
        if #available(iOS 14.0, *) {
            button.showsMenuAsPrimaryAction = true
            button.menu = UIMenu(children: [])
        }
        button.accessibilityLabel = UIConstants.strings.browserSettings
        button.accessibilityIdentifier = "HomeView.settingsButton"
        button.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private var cancellables = Set<AnyCancellable>()

    private lazy var shieldIconButton: UIButton = {
        let button = UIButton()
        button.setImage(.trackingProtectionOn, for: .normal)
        button.contentMode = .center
        button.accessibilityIdentifier = "URLBar.trackingProtectionIcon"
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: .barButtonHeight)
        ])
        return button
    }()

    private let domainCompletion = DomainCompletion(completionSources: [TopDomainsCompletionSource(), CustomCompletionSource()])

    private var centerURLBar = false {
        didSet {
            guard oldValue != centerURLBar else { return }

        }
    }

    private var hidePageActions = true {
        didSet {
            guard oldValue != hidePageActions else { return }

        }
    }

    private var showToolset = false {
        didSet {
            guard oldValue != showToolset else { return }
            isIPadRegularDimensions = showToolset
            guard UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone else { return }
            showToolset = false
        }
    }

    private var compressBar = true {
        didSet {
            guard oldValue != compressBar else { return }
        }
    }

    private var showLeftBar = false {
        didSet {
            guard oldValue != showLeftBar else { return }
        }
    }

    public override var canBecomeFirstResponder: Bool { true }

    private var viewModel: URLBarViewModel

    private func bindButtonActions() {
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

    private func bindViewModelEvents() {
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
                backButton.alpha = $0 ? 1 : UIConstants.layout.browserToolbarDisabledOpacity
            }
            .store(in: &cancellables)

        viewModel
            .$canGoForward
            .sink { [forwardButton] in
                forwardButton.isEnabled = $0
                forwardButton.alpha = $0 ? 1 : UIConstants.layout.browserToolbarDisabledOpacity
            }
            .store(in: &cancellables)

        viewModel
            .$canDelete
            .sink { [deleteButton] in
                deleteButton.isEnabled = $0
                deleteButton.alpha = $0 ? 1 : UIConstants.layout.browserToolbarDisabledOpacity
            }
            .store(in: &cancellables)

        viewModel
            .$isLoading
            .sink { [stopReloadButton] in
                if $0 {
                    stopReloadButton.setImage(#imageLiteral(resourceName: "icon_stop_menu"), for: .normal)
                    stopReloadButton.accessibilityLabel = UIConstants.strings.browserStop
                } else {
                    stopReloadButton.setImage(#imageLiteral(resourceName: "icon_refresh_menu"), for: .normal)
                    stopReloadButton.accessibilityLabel = UIConstants.strings.browserReload
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
            cancelButton.animateHideFromSuperview()
            shieldIconButton.fadeIn()
        }
    }

    func adaptUI(for browsingState: URLBarViewModel.BrowsingState, orientation: URLBarViewModel.Orientation) {
        switch (browsingState, orientation) {
            case (.home, _):
                stopReloadButton.animateHideFromSuperview()
                stackView.addArrangedSubview(contextMenuButton)
                contextMenuButton.fadeIn()
                forwardButton.animateHideFromSuperview()
                backButton.animateHideFromSuperview()
                deleteButton.animateHideFromSuperview()

            case (.browsing, .portrait):
                stopReloadButton
                    .fadeIn(
                        firstDo: { [urlStackView, stopReloadButton] in
                            urlStackView.appendArrangedSubview(stopReloadButton)
                        })

                contextMenuButton.animateHideFromSuperview()
                forwardButton.animateHideFromSuperview()
                backButton.animateHideFromSuperview()
                deleteButton.animateHideFromSuperview()

            case (.browsing, .landscape):
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

    init(viewModel: URLBarViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        bindButtonActions()
        bindViewModelEvents()

        isIPadRegularDimensions = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(sender:)))
        singleTap.numberOfTapsRequired = 1
        truncatedUrlText.addGestureRecognizer(singleTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(displayURLContextMenu))
        urlStackView.addGestureRecognizer(longPress)

        let dragInteraction = UIDragInteraction(delegate: self)
        urlStackView.addInteraction(dragInteraction)

        addSubview(urlBarBackgroundView)
        addSubview(stackView)
        addSubview(truncatedUrlText)
        addSubview(progressBar)

        NSLayoutConstraint.activate([
            truncatedUrlText.centerXAnchor.constraint(equalTo: centerXAnchor),
            truncatedUrlText.heightAnchor.constraint(equalToConstant: UIConstants.layout.collapsedUrlBarHeight),
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

            progressBar.heightAnchor.constraint(equalToConstant: UIConstants.layout.progressBarHeight),
            progressBar.topAnchor.constraint(equalTo: bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateURLBarLayoutAfterSplitView() {
    }

    private func displayClearButton(shouldDisplay: Bool, animated: Bool = true) {
        // Prevent the rightView's position from being animated
        urlTextField.rightView?.layer.removeAllAnimations()
        urlTextField.rightView?.animateHidden(!shouldDisplay, duration: animated ? UIConstants.layout.urlBarTransitionAnimationDuration : 0)
    }

    private func addCustomURL() {
        guard let url = self.url else { return }
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.quickAddCustomDomainButton)
        delegate?.urlBar(self, didAddCustomURL: url)
    }

    public func copyToClipboard() {
        UIPasteboard.general.string = self.url?.absoluteString ?? ""
    }

    private func paste(clipboardString: String) {
        viewModel.selectionState = .selected
        urlTextField.text = clipboardString
    }

    private func pasteAndGo(clipboardString: String) {
        viewModel.selectionState = .selected
        delegate?.urlBarDidActivate(self)
        delegate?.urlBar(self, didSubmitText: clipboardString)

        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.pasteAndGo)
        GleanMetrics.UrlInteraction.pasteAndGo.record()
    }

    @objc private func copyLink() {
        self.url
            .map(\.absoluteString)
            .map { UIPasteboard.general.string = $0 }
    }

    @objc private func pasteAndGoFromContextMenu() {
        guard let clipboardString = UIPasteboard.general.string else { return }
        pasteAndGo(clipboardString: clipboardString)
    }

    // Adds Menu Item
    private func addCustomMenu() {
        var items = [UIMenuItem]()

        if urlTextField.text != nil, urlTextField.text?.isEmpty == false {
            let copyItem = UIMenuItem(title: UIConstants.strings.copyMenuButton, action: #selector(copyLink))
            items.append(copyItem)
        }

        if UIPasteboard.general.hasStrings {
            let lookupMenu = UIMenuItem(title: UIConstants.strings.urlPasteAndGo, action: #selector(pasteAndGoFromContextMenu))
            items.append(lookupMenu)
        }

        UIMenuController.shared.menuItems = items
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        addCustomMenu()
        return super.canPerformAction(action, withSender: sender)
    }

    public var shouldShowToolset: Bool = false {
        didSet {

        }
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
    @objc private func cancelPressed() {
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

    @objc private func didSingleTap(sender: UITapGestureRecognizer) {
        delegate?.urlBarDidPressScrollTop(self, tap: sender)
    }

    // MARK: - URL

    public var url: URL? = nil {
        didSet {
            if !urlTextField.isEditing {
                setTextToURL()
            }
        }
    }

    public private(set) var userInputText: String?

    @objc private func didPressClear() {
        urlTextField.text = nil
        userInputText = nil
        displayClearButton(shouldDisplay: false)
        delegate?.urlBar(self, didEnterText: "")
    }

    public func fillUrlBar(text: String) {
        urlTextField.text = text
    }

    private func setTextToURL(displayFullUrl: Bool = false) {
        guard let url = url else {
            urlTextField.text = nil
            userInputText = nil
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

    @objc private func displayURLContextMenu(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.urlBarDidLongPress(self)
            self.isUserInteractionEnabled = true
            self.becomeFirstResponder()
            UIMenuController.shared.showMenu(from: self, rect: self.bounds)
        }
    }

    private func deactivate() {
        urlTextField.text = nil
        displayClearButton(shouldDisplay: false)

        UIView.animate(withDuration: UIConstants.layout.urlBarTransitionAnimationDuration, animations: {
            self.layoutIfNeeded()
        })

        delegate?.urlBarDidDeactivate(self)
    }

    private func highlightText(_ textField: UITextField) {
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

    private func collapseUrlBar(expandAlpha: CGFloat, collapseAlpha: CGFloat) {
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
}

extension URLBar: AutocompleteTextFieldDelegate {
    func autocompleteTextFieldShouldClear(_ autocompleteTextField: AutocompleteTextField) -> Bool { return false }

    func autocompleteTextFieldDidCancel(_ autocompleteTextField: AutocompleteTextField) { }

    func autocompletePasteAndGo(_ autocompleteTextField: AutocompleteTextField) { }

    func autocompleteTextFieldShouldEndEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool { return true }

    func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool {

        setTextToURL(displayFullUrl: true)

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
        if let autocompleteText = autocompleteTextField.text, autocompleteText != userInputText {
            Telemetry.default.recordEvent(TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.autofill))
        }
        userInputText = nil

        delegate?.urlBar(self, didSubmitText: autocompleteTextField.text ?? "")

        if Settings.getToggle(.enableSearchSuggestions) {
            Telemetry.default.recordEvent(TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.searchSuggestionNotSelected))
        }

        return true
    }

    func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didEnterText text: String) {
        if let oldValue = userInputText, oldValue.count < text.count {
            let completion = domainCompletion.autocompleteTextFieldCompletionSource(autocompleteTextField, forText: text)
            autocompleteTextField.setAutocompleteSuggestion(completion)
        }

        userInputText = text

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
        guard let url = url, let itemProvider = NSItemProvider(contentsOf: url) else { return [] }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.drag, object: TelemetryEventObject.searchBar)
        GleanMetrics.UrlInteraction.dragStarted.record()
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
                guard let url = self.url else {
                    return UIDragPreview(view: UIView())
                }
                return UIDragPreview(for: url)
            }
        }
    }
}

// MARK: - Progress bar API

public extension URLBar {
    func hideProgressBar() {
        progressBar.hideProgressBar()
    }

    func showProgressBar(estimatedProgress: Double) {
        progressBar.alpha = 1
        progressBar.isHidden = false
        progressBar.setProgress(Float(estimatedProgress), animated: true)
    }
}

fileprivate extension CGFloat {
    static var barButtonHeight: CGFloat = 44
    static let urlBarHeight: CGFloat = 44
}
