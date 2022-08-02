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

    public enum Selection: Equatable {
        case selected
        case unselected

        var isSelecting: Bool { self == .selected }
    }

    public enum BrowsingState {
        case home
        case browsing

        var isBrowsingMode: Bool { self == .browsing }
    }

    private(set) public var selectionState = Selection.unselected {
        didSet {
            guard oldValue != selectionState else { return }
            updateViews()

            if oldValue.isSelecting {
                _ = urlTextField.resignFirstResponder()
                delegate?.urlBarDidDismiss(self)
            } else if selectionState.isSelecting {
                delegate?.urlBarDidFocus(self)
            }
        }
    }

    private(set) public var state = BrowsingState.home {
        didSet {
            guard oldValue != state else { return }
            updateViews()
        }
    }

    public func update(state: BrowsingState) {
        self.state = state
    }

    public weak var delegate: URLBarDelegate?
    public var userInputText: String?
    public var shouldPresent = false
    public var isIPadRegularDimensions = false {
        didSet {
            updateViews()
            updateURLBarLayoutAfterSplitView()
        }
    }

    // MARK: - UI Components

    public var contextMenuButtonAnchor: UIView { contextMenuButton }
    public var deleteButtonAnchor: UIView { deleteButton }
    public var shieldIconButtonAnchor: UIView { shieldIconButton }

    private var draggableUrlTextView: UIView { urlTextField }

    private lazy var urlTextField: URLTextField = {
        let urlTextField = URLTextField()

        // UITextField doesn't allow customization of the clear button, so we create
        // our own so we can use it as the rightView.
        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIConstants.layout.urlBarClearButtonWidth, height: UIConstants.layout.urlBarClearButtonHeight))
        clearButton.isHidden = true
        clearButton.setImage(#imageLiteral(resourceName: "icon_clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(didPressClear), for: .touchUpInside)

        urlTextField.font = .body15
        urlTextField.tintColor = .primaryText
        urlTextField.textColor = .primaryText
        urlTextField.keyboardType = .webSearch
        urlTextField.autocapitalizationType = .none
        urlTextField.autocorrectionType = .no
        urlTextField.rightView = clearButton
        urlTextField.rightViewMode = .whileEditing
        urlTextField.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .vertical)
        urlTextField.autocompleteDelegate = self
        urlTextField.accessibilityIdentifier = "URLBar.urlText"
        urlTextField.placeholder = UIConstants.strings.urlTextPlaceholder
        urlTextField.isUserInteractionEnabled = false
        return urlTextField
    }()

    private lazy var truncatedUrlText: UITextView = {
        let truncatedUrlText = UITextView()
        truncatedUrlText.alpha = 0
        truncatedUrlText.isUserInteractionEnabled = false
        truncatedUrlText.font = .footnote12
        truncatedUrlText.tintColor = .primaryText
        truncatedUrlText.textColor = .primaryText
        truncatedUrlText.backgroundColor = UIColor.clear
        truncatedUrlText.contentMode = .bottom
        truncatedUrlText.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .vertical)
        truncatedUrlText.isScrollEnabled = false
        truncatedUrlText.accessibilityIdentifier = "Collapsed.truncatedUrlText"
        return truncatedUrlText
    }()

    private let progressBar: GradientProgressBar = {
        let progressBar = GradientProgressBar(progressViewStyle: .bar)
        progressBar.isHidden = true
        progressBar.alpha = 0
        return progressBar
    }()

    private lazy var cancelButton: InsetButton = {
        let cancelButton = InsetButton()
        cancelButton.isHidden = true
        cancelButton.alpha = 0
        cancelButton.setImage(#imageLiteral(resourceName: "icon_cancel"), for: .normal)

        cancelButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        cancelButton.accessibilityIdentifier = "URLBar.cancelButton"
        return cancelButton
    }()

    private let urlBarBorderView: UIView = {
        let urlBarBorderView = UIView()
        urlBarBorderView.backgroundColor = .secondaryButton
        urlBarBorderView.layer.cornerRadius = UIConstants.layout.urlBarCornerRadius
        urlBarBorderView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        urlBarBorderView.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        return urlBarBorderView
    }()

    private let urlBarBackgroundView: UIView = {
        let urlBarBackgroundView = UIView()
        urlBarBackgroundView.backgroundColor = .locationBar
        urlBarBackgroundView.layer.cornerRadius = UIConstants.layout.urlBarCornerRadius
        urlBarBackgroundView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        urlBarBackgroundView.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .horizontal)
        return urlBarBackgroundView
    }()

    private lazy var backButton: InsetButton = {
        let backButton = InsetButton()
        backButton.setImage(#imageLiteral(resourceName: "icon_back_active"), for: .normal)
        backButton.addTarget(self, action: #selector(didPressBack), for: .touchUpInside)
        backButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        backButton.accessibilityLabel = UIConstants.strings.browserBack
        backButton.isEnabled = false
        return backButton
    }()

    private lazy var forwardButton: InsetButton = {
        let forwardButton = InsetButton()
        forwardButton.setImage(#imageLiteral(resourceName: "icon_forward_active"), for: .normal)
        forwardButton.addTarget(self, action: #selector(didPressForward), for: .touchUpInside)
        forwardButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        forwardButton.accessibilityLabel = UIConstants.strings.browserForward
        forwardButton.isEnabled = false
        return forwardButton
    }()

    private lazy var stopReloadButton: InsetButton = {
        let stopReloadButton = InsetButton()
        stopReloadButton.setImage(#imageLiteral(resourceName: "icon_refresh_menu"), for: .normal)
        stopReloadButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        stopReloadButton.addTarget(self, action: #selector(didPressStopReload), for: .touchUpInside)
        stopReloadButton.accessibilityIdentifier = "BrowserToolset.stopReloadButton"
        return stopReloadButton
    }()

    private lazy var deleteButton: InsetButton = {
        let deleteButton = InsetButton()
        deleteButton.setImage(#imageLiteral(resourceName: "icon_delete"), for: .normal)
        deleteButton.addTarget(self, action: #selector(didPressDelete), for: .touchUpInside)
        deleteButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        deleteButton.accessibilityIdentifier = "URLBar.deleteButton"
        deleteButton.isEnabled = false
        return deleteButton
    }()

    private lazy var contextMenuButton: InsetButton = {
        let contextMenuButton = InsetButton()
        contextMenuButton.setImage(#imageLiteral(resourceName: "icon_hamburger_menu"), for: .normal)
        contextMenuButton.tintColor = .primaryText
        if #available(iOS 14.0, *) {
            contextMenuButton.showsMenuAsPrimaryAction = true
            contextMenuButton.menu = UIMenu(children: [])
            contextMenuButton.addTarget(self, action: #selector(didPressContextMenu), for: .menuActionTriggered)
        } else {
            contextMenuButton.addTarget(self, action: #selector(didPressContextMenu), for: .touchUpInside)
        }
        contextMenuButton.accessibilityLabel = UIConstants.strings.browserSettings
        contextMenuButton.accessibilityIdentifier = "HomeView.settingsButton"
        contextMenuButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        contextMenuButton.imageView?.snp.makeConstraints { $0.size.equalTo(UIConstants.layout.contextMenuIconSize) }
        return contextMenuButton
    }()

    // MARK: - Toolset

    public weak var toolsetDelegate: BrowserToolsetDelegate?

    @objc private func didPressBack() {
        toolsetDelegate?.browserToolsetDidPressBack()
    }

    @objc private func didPressForward() {
        toolsetDelegate?.browserToolsetDidPressForward()
    }

    @objc private func didPressStopReload() {
        if viewModel.isLoading {
            toolsetDelegate?.browserToolsetDidPressStop()
        } else {
            toolsetDelegate?.browserToolsetDidPressReload()
        }
    }

    @objc func didPressDelete() {
        if viewModel.canDelete {
            toolsetDelegate?.browserToolsetDidPressDelete()
        }
    }

    @objc private func didPressContextMenu(_ sender: InsetButton) {
        toolsetDelegate?.browserToolsetDidPressContextMenu(menuButton: sender)
    }

    private let textAndLockContainer = UIView()
    private let collapsedUrlAndLockWrapper = UIView()
    private var cancellables = Set<AnyCancellable>()

    private lazy var shieldIconButton: UIButton = {
        let button = UIButton()
        button.setImage(.trackingProtectionOn, for: .normal)
        button.contentMode = .center
        button.accessibilityIdentifier = "URLBar.trackingProtectionIcon"
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    private lazy var collapsedTrackingProtectionBadge: UIButton = {
        let button = UIButton()
        button.alpha = 0
        button.setImage(.trackingProtectionOn, for: .normal)
        button.contentMode = .center
        button.accessibilityIdentifier = "URLBar.trackingProtectionIcon"
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    private let leftBarViewLayoutGuide = UILayoutGuide()
    private let rightBarViewLayoutGuide = UILayoutGuide()
    private let domainCompletion = DomainCompletion(completionSources: [TopDomainsCompletionSource(), CustomCompletionSource()])

    private var centerURLBar = false {
        didSet {
            guard oldValue != centerURLBar else { return }
            activateConstraints(centerURLBar, shownConstraints: centeredURLConstraints, hiddenConstraints: fullWidthURLConstraints)
        }
    }
    private var centeredURLConstraints = [Constraint]()
    private var fullWidthURLConstraints = [Constraint]()
    private var editingURLTextConstrains = [Constraint]()

    private var hidePageActions = true {
        didSet {
            guard oldValue != hidePageActions else { return }
            activateConstraints(hidePageActions, shownConstraints: showPageActionsConstraints, hiddenConstraints: hidePageActionsConstraints)
        }
    }
    private var hidePageActionsConstraints = [Constraint]()
    private var showPageActionsConstraints = [Constraint]()

    private var showToolset = false {
        didSet {
            guard oldValue != showToolset else { return }
            isIPadRegularDimensions = showToolset
            activateConstraints(showToolset, shownConstraints: showToolsetConstraints, hiddenConstraints: hideToolsetConstraints)
            guard UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone else { return }
            showToolset = false
        }
    }
    private var hideToolsetConstraints = [Constraint]()
    private var showToolsetConstraints = [Constraint]()

    private var compressBar = true {
        didSet {
            guard oldValue != compressBar else { return }
            activateConstraints(compressBar, shownConstraints: compressedBarConstraints, hiddenConstraints: expandedBarConstraints)
        }
    }
    private var compressedBarConstraints = [Constraint]()
    private var expandedBarConstraints = [Constraint]()

    private var showLeftBar = false {
        didSet {
            guard oldValue != showLeftBar else { return }
            activateConstraints(showLeftBar, shownConstraints: showLeftBarViewConstraints, hiddenConstraints: hideLeftBarViewConstraints)
        }
    }
    private var showLeftBarViewConstraints = [Constraint]()
    private var hideLeftBarViewConstraints = [Constraint]()

    public override var canBecomeFirstResponder: Bool { true }

    var viewModel: URLBarViewModel

    private func bindButtonActions() {
        shieldIconButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.shieldIconButtonTap)
            }
            .store(in: &cancellables)
    }

    private func bindViewModelEvents() {
        viewModel
            .connectionStatePublisher
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
    }

    init(viewModel: URLBarViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        bindButtonActions()
        bindViewModelEvents()

        isIPadRegularDimensions = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(sender:)))
        singleTap.numberOfTapsRequired = 1
        textAndLockContainer.addGestureRecognizer(singleTap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(displayURLContextMenu))
        textAndLockContainer.addGestureRecognizer(longPress)

        let dragInteraction = UIDragInteraction(delegate: self)
        textAndLockContainer.addInteraction(dragInteraction)

        addSubview(backButton)
        addSubview(forwardButton)
        addSubview(deleteButton)
        addSubview(contextMenuButton)
        urlBarBackgroundView.addSubview(textAndLockContainer)
        addSubview(cancelButton)
        textAndLockContainer.addSubview(stopReloadButton)
        addSubview(urlBarBorderView)
        urlBarBorderView.addSubview(urlBarBackgroundView)
        collapsedUrlAndLockWrapper.addSubview(truncatedUrlText)
        collapsedUrlAndLockWrapper.addSubview(collapsedTrackingProtectionBadge)
        addSubview(collapsedUrlAndLockWrapper)
        textAndLockContainer.addSubview(urlTextField)
        addSubview(shieldIconButton)
        addSubview(progressBar)

        var toolsetButtonWidthMultiplier: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 0.04
            } else {
                return 0.05
            }
        }

        addLayoutGuide(leftBarViewLayoutGuide)
        leftBarViewLayoutGuide.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(UIConstants.layout.urlBarButtonTargetSize)
            make.width.equalTo(UIConstants.layout.urlBarButtonTargetSize).priority(900)

            hideToolsetConstraints.append(make.leading.equalTo(leftBarViewLayoutGuide).offset(UIConstants.layout.urlBarMargin).constraint)

            showToolsetConstraints.append(make.leading.equalTo( forwardButton.snp.trailing).offset(UIConstants.layout.urlBarToolsetOffset).constraint)
        }

        addLayoutGuide(rightBarViewLayoutGuide)
        rightBarViewLayoutGuide.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(UIConstants.layout.urlBarButtonTargetSize)

            hideToolsetConstraints.append(make.trailing.equalTo(contextMenuButton.snp.leading).offset(-UIConstants.layout.urlBarIPadToolsetOffset).constraint)

            showToolsetConstraints.append(make.trailing.equalTo(contextMenuButton.snp.leading).offset(-UIConstants.layout.urlBarIPadToolsetOffset).constraint)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(UIConstants.layout.urlBarMargin)
            make.centerY.equalTo(self)
            make.width.equalTo(self).multipliedBy(toolsetButtonWidthMultiplier)
        }

        forwardButton.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing)
            make.centerY.equalTo(self)
            make.size.equalTo(backButton)
        }

        contextMenuButton.snp.makeConstraints { make in
            if state.isBrowsingMode {
                make.trailing.equalTo(safeAreaLayoutGuide)
            } else {
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-UIConstants.layout.contextMenuButtonMargin)
            }
            make.centerY.equalTo(self)
            make.size.equalTo(UIConstants.layout.contextMenuButtonSize)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalTo(contextMenuButton.snp.leading).inset(isIPadRegularDimensions ? UIConstants.layout.deleteButtonOffset : UIConstants.layout.deleteButtonMarginContextMenu)
            make.centerY.equalTo(self)
            make.size.equalTo(backButton)
        }

        urlBarBorderView.snp.makeConstraints { make in
            make.height.equalTo(UIConstants.layout.urlBarBorderHeight).priority(.medium)
            make.top.bottom.equalToSuperview().inset(UIConstants.layout.urlBarMargin)

            compressedBarConstraints.append(make.height.equalTo(UIConstants.layout.urlBarBorderHeight).constraint)
            if state.isBrowsingMode {
                compressedBarConstraints.append(make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).inset(UIConstants.layout.urlBarMargin).constraint)
            } else {
                compressedBarConstraints.append(make.trailing.equalTo(contextMenuButton.snp.leading).offset(-UIConstants.layout.contextMenuButtonMargin).constraint)
            }

            expandedBarConstraints.append(make.trailing.equalTo(rightBarViewLayoutGuide.snp.trailing).constraint)

            showLeftBarViewConstraints.append(make.leading.lessThanOrEqualTo(leftBarViewLayoutGuide.snp.trailing).offset(UIConstants.layout.urlBarIconInset).constraint)

            hideLeftBarViewConstraints.append(make.leading.equalTo(shieldIconButton.snp.leading).offset(-UIConstants.layout.urlBarIconInset).constraint)

            showToolsetConstraints.append(make.leading.equalTo(leftBarViewLayoutGuide.snp.leading).offset(UIConstants.layout.urlBarIconInset).constraint)
        }

        urlBarBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIConstants.layout.urlBarBorderInset)
        }

        addShieldConstraints()

        cancelButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(leftBarViewLayoutGuide)
            make.top.bottom.equalToSuperview()
        }

        textAndLockContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().priority(999)
            make.trailing.equalToSuperview()

            showLeftBarViewConstraints.append(make.leading.equalTo(leftBarViewLayoutGuide.snp.trailing).offset(UIConstants.layout.urlBarIconInset).constraint)

            hideLeftBarViewConstraints.append(make.leading.equalToSuperview().offset(UIConstants.layout.urlBarTextInset).constraint)
            centeredURLConstraints.append(make.centerX.equalToSuperview().constraint)
        }

        stopReloadButton.snp.makeConstraints { make in
            make.trailing.equalTo(urlBarBorderView)
            make.leading.equalTo(urlBarBorderView.snp.trailing).inset(UIConstants.layout.urlBarButtonTargetSize)
            make.center.equalToSuperview()
        }

        urlTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(shieldIconButton.snp.trailing).offset(5)

            showLeftBarViewConstraints.append(make.left.equalToSuperview().constraint)

            hidePageActionsConstraints.append(make.trailing.equalToSuperview().constraint)
            showPageActionsConstraints.append(make.trailing.equalTo(urlBarBorderView.snp.trailing).inset(UIConstants.layout.urlBarButtonTargetSize).constraint)
        }

        progressBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(UIConstants.layout.progressBarHeight)
            make.height.equalTo(UIConstants.layout.progressBarHeight)
        }

        collapsedTrackingProtectionBadge.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(UIConstants.layout.collapsedProtectionBadgeOffset)
            make.width.height.equalTo(10)
            make.bottom.equalToSuperview()
        }

        truncatedUrlText.snp.makeConstraints { make in
            make.centerY.equalTo(self).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(UIConstants.layout.truncatedUrlTextOffset)
        }

        collapsedUrlAndLockWrapper.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.bottom.equalTo(truncatedUrlText)
            make.height.equalTo(UIConstants.layout.collapsedUrlBarHeight)
            make.leading.equalTo(truncatedUrlText)
            make.trailing.equalTo(truncatedUrlText)
        }

        hideLeftBarViewConstraints.forEach { $0.activate() }
        showLeftBarViewConstraints.forEach { $0.deactivate() }
        showToolsetConstraints.forEach { $0.deactivate() }
        expandedBarConstraints.forEach { $0.activate() }
        updateToolsetConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addShieldConstraints() {
        shieldIconButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(leftBarViewLayoutGuide).inset(isIPadRegularDimensions ? UIConstants.layout.shieldIconIPadInset : UIConstants.layout.shieldIconInset)
            make.width.equalTo(UIConstants.layout.urlButtonSize)
        }
    }

    private func updateURLBarLayoutAfterSplitView() {

        shieldIconButton.snp.removeConstraints()
        addShieldConstraints()

        if isIPadRegularDimensions {
            leftBarViewLayoutGuide.snp.remakeConstraints { (make) in
                make.leading.equalTo(forwardButton.snp.trailing).offset(UIConstants.layout.urlBarToolsetOffset)
            }
        } else {
            leftBarViewLayoutGuide.snp.makeConstraints { make in
                make.leading.equalTo(safeAreaLayoutGuide).offset(UIConstants.layout.urlBarMargin)
            }
        }

        rightBarViewLayoutGuide.snp.makeConstraints { (make) in
            if  isIPadRegularDimensions {
                make.trailing.equalTo(contextMenuButton.snp.leading).offset(-UIConstants.layout.urlBarIPadToolsetOffset)
            } else {
                make.trailing.greaterThanOrEqualTo(contextMenuButton.snp.leading).offset(-UIConstants.layout.urlBarToolsetOffset)
            }
        }
    }

    public func activateTextField() {
        urlTextField.isUserInteractionEnabled = true
        urlTextField.becomeFirstResponder()
        highlightText(urlTextField)
        selectionState = .selected
    }

    private func displayClearButton(shouldDisplay: Bool, animated: Bool = true) {
        // Prevent the rightView's position from being animated
        urlTextField.rightView?.layer.removeAllAnimations()
        urlTextField.rightView?.animateHidden(!shouldDisplay, duration: animated ? UIConstants.layout.urlBarTransitionAnimationDuration : 0)
    }

    public func dismissTextField() {
        urlTextField.isUserInteractionEnabled = false
        urlTextField.endEditing(true)
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
        selectionState = .selected
        activateTextField()
        urlTextField.text = clipboardString
    }

    private func pasteAndGo(clipboardString: String) {
        selectionState = .selected
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

    public var url: URL? = nil {
        didSet {
            if !urlTextField.isEditing {
                setTextToURL()
                updateUrlIcons()
            }
        }
    }

    public var shouldShowToolset: Bool = false {
        didSet {
            updateViews()
            updateToolsetConstraints()
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
        state = .browsing
    }

    public func fillUrlBar(text: String) {
        urlTextField.text = text
    }

    private func updateUrlIcons() {
        let visible = !selectionState.isSelecting && url != nil
        let duration = UIConstants.layout.urlBarTransitionAnimationDuration / 2

        stopReloadButton.animateHidden(!visible, duration: duration)

        self.layoutIfNeeded()

        UIView.animate(withDuration: duration) {
            if visible {
                self.hidePageActionsConstraints.forEach { $0.deactivate() }
                self.showPageActionsConstraints.forEach { $0.activate() }
            } else {
                self.showPageActionsConstraints.forEach { $0.deactivate() }
                self.hidePageActionsConstraints.forEach { $0.activate() }
            }
            self.layoutIfNeeded()
        }
    }

    private func updateViews() {
        self.updateToolsetConstraints()
        UIView.animate(withDuration: UIConstants.layout.urlBarTransitionAnimationDuration, animations: {
            self.layoutIfNeeded()
        })

        updateUrlIcons()
        displayClearButton(shouldDisplay: false)
        self.layoutIfNeeded()

        var borderColor: UIColor
        var showBackgroundView: Bool

        switch state {
        case .home:
            showLeftBar = false
            compressBar = isIPadRegularDimensions ? false : true
            showBackgroundView = true

            shieldIconButton.animateHidden(false, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
            cancelButton.animateHidden(true, duration: UIConstants.layout.urlBarTransitionAnimationDuration)

            setTextToURL()
            deactivate()
            borderColor = .foundation
            backgroundColor = .clear

        case .browsing:
            showLeftBar = shouldShowToolset ? true : false
            compressBar = isIPadRegularDimensions ? false : true
            showBackgroundView = false

            shieldIconButton.animateHidden(false, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
            cancelButton.animateHidden(true, duration: UIConstants.layout.urlBarTransitionAnimationDuration)

            setTextToURL()
            borderColor = .foundation
            backgroundColor = .clear

            editingURLTextConstrains.forEach { $0.deactivate() }
            urlTextField.snp.makeConstraints { make in
                make.leading.equalTo(shieldIconButton.snp.trailing).offset(UIConstants.layout.urlTextOffset)
            }
        }

        switch selectionState {
        case .selected:
            showLeftBar = !shouldShowToolset && isIPadRegularDimensions ? false : true
            compressBar = isIPadRegularDimensions ? false : true
            showBackgroundView = true

            if isIPadRegularDimensions && state.isBrowsingMode {
                leftBarViewLayoutGuide.snp.makeConstraints { make in
                    editingURLTextConstrains.append(make.leading.equalTo(urlTextField).offset(-UIConstants.layout.urlTextOffset).constraint)
                }
                editingURLTextConstrains.forEach { $0.activate() }
                stopReloadButton.animateHidden(true, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
            }
            if !isIPadRegularDimensions {
                leftBarViewLayoutGuide.snp.makeConstraints { make in
                    make.leading.equalTo(safeAreaLayoutGuide).offset(UIConstants.layout.urlBarMargin)
                }
            }

            shieldIconButton.animateHidden(true, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
            cancelButton.animateHidden(isIPadRegularDimensions ? true : false, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
            contextMenuButton.isEnabled = true
            borderColor = .foundation
            backgroundColor = .clear

        case .unselected:
            showLeftBar = false
            compressBar = isIPadRegularDimensions ? false : true
            showBackgroundView = true

            shieldIconButton.animateHidden(false, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
            cancelButton.animateHidden(true, duration: UIConstants.layout.urlBarTransitionAnimationDuration)

            setTextToURL()
            borderColor = .foundation
            backgroundColor = .clear
        }

        UIView.animate(withDuration: UIConstants.layout.urlBarTransitionAnimationDuration, animations: {
            self.layoutIfNeeded()

            if self.state.isBrowsingMode && !self.isIPadRegularDimensions {
                self.updateURLBorderConstraints()
            }

            self.urlBarBackgroundView.snp.remakeConstraints { make in
                make.edges.equalToSuperview().inset(showBackgroundView ? UIConstants.layout.urlBarBorderInset : 1)
            }

            self.urlBarBorderView.backgroundColor = borderColor
        }, completion: { finished in
            if finished {
                if let isEmpty = self.urlTextField.text?.isEmpty {
                    self.displayClearButton(shouldDisplay: !isEmpty)
                }
            }
        })
    }

    private func updateURLBorderConstraints() {
        self.urlBarBorderView.snp.remakeConstraints { make in
            make.height.equalTo(UIConstants.layout.urlBarBorderHeight).priority(.medium)
            make.top.bottom.equalToSuperview().inset(UIConstants.layout.urlBarMargin)

            compressedBarConstraints.append(make.height.equalTo(UIConstants.layout.urlBarBorderHeight).constraint)
            if state.isBrowsingMode {
                compressedBarConstraints.append(make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).inset(UIConstants.layout.urlBarMargin).constraint)
            } else {
                compressedBarConstraints.append(make.trailing.equalTo(contextMenuButton.snp.leading).offset(-UIConstants.layout.urlBarMargin).constraint)
            }

            if selectionState.isSelecting {
                make.leading.equalTo(leftBarViewLayoutGuide.snp.trailing).offset(UIConstants.layout.urlBarIconInset)
            } else {
                make.leading.equalTo(shieldIconButton.snp.leading).offset(-UIConstants.layout.urlBarIconInset)
            }
        }
    }

    /* This separate @objc function is necessary as selector methods pass sender by default. Calling
     dismiss() directly from a selector would pass the sender as "completion" which results in a crash. */
    @objc private func cancelPressed() {
        selectionState = .unselected
    }

    public func dismiss(completion: (() -> Void)? = nil) {
        guard selectionState.isSelecting else {
            completion?()
            return
        }

        selectionState = .unselected
        completion?()
    }

    @objc private func didSingleTap(sender: UITapGestureRecognizer) {
        delegate?.urlBarDidPressScrollTop(self, tap: sender)
    }

    /// Show the URL toolset buttons if we're on iPad/landscape and not editing; hide them otherwise.
    /// This method is intended to be called inside `UIView.animate` block.
    private func updateToolsetConstraints() {
        var isHidden: Bool

        switch state {
        case .home:
            isHidden = true
            showToolset = false
            centerURLBar = false
        case .browsing:
            isHidden = !shouldShowToolset
            showToolset = !isHidden
            centerURLBar = shouldShowToolset
        }

        switch selectionState {
        case .selected:
            let isiPadLayoutWhileBrowsing = isIPadRegularDimensions && state.isBrowsingMode
            isHidden =  isiPadLayoutWhileBrowsing ? !shouldShowToolset : true
            showToolset = isiPadLayoutWhileBrowsing ? !isHidden : false
            centerURLBar = false

        case .unselected:
            isHidden = true
            showToolset = false
            centerURLBar = false
        }

        backButton.animateHidden(isHidden, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
        forwardButton.animateHidden(isHidden, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
        deleteButton.animateHidden(isHidden, duration: UIConstants.layout.urlBarTransitionAnimationDuration)
        contextMenuButton.animateHidden(!state.isBrowsingMode ? false : (isIPadRegularDimensions ? false : isHidden), duration: UIConstants.layout.urlBarTransitionAnimationDuration)

    }

    @objc private func didPressClear() {
        urlTextField.text = nil
        userInputText = nil
        displayClearButton(shouldDisplay: false)
        delegate?.urlBar(self, didEnterText: "")
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

    private func setTextToURL(displayFullUrl: Bool = false) {
        guard let url = url else { return }

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
    private func highlightText(_ textField: UITextField) {
        guard textField.text != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            textField.selectAll(nil)
        }
    }

    private func activateConstraints(_ activate: Bool, shownConstraints: [Constraint]?, hiddenConstraints: [Constraint]?) {
        (activate ? hiddenConstraints : shownConstraints)?.forEach { $0.deactivate() }
        (activate ? shownConstraints : hiddenConstraints)?.forEach { $0.activate() }
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
        collapsedUrlAndLockWrapper.alpha = collapseAlpha
        backButton.alpha = shouldShowToolset ? expandAlpha : 0
        forwardButton.alpha = shouldShowToolset ? expandAlpha : 0
        deleteButton.alpha = shouldShowToolset ? expandAlpha : 0
        contextMenuButton.alpha = expandAlpha

        collapsedTrackingProtectionBadge.alpha = 0
        if selectionState.isSelecting {
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

        if !selectionState.isSelecting {
            selectionState = .selected
            delegate?.urlBarDidActivate(self)
        }

        // When text.characters.count == 0, it is the HomeView
        if let text = autocompleteTextField.text, !selectionState.isSelecting, text.count == 0 {
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

        if !selectionState.isSelecting && shouldPresent {
            selectionState = .selected
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
