import UIKit
import SwiftUI
import SnapKit
import Combine
import UIHelpers
import DesignSystem

typealias UISpacer = UIView

public class URLBarView: UIView {
    
    private let leftSpacer = UISpacer()
    private let rightSpacer = UISpacer()
    
    
    // MARK: Stack View Containers
    
    private var views: [UIView] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                urlStackView,
                menuStackView
            ]
        } else {
            return [
                leftSpacer,
                urlStackView,
                rightSpacer,
                menuStackView
            ]
        }
    }
    
    private lazy var urlBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .locationBar
        view.layer.cornerRadius = UIConstants.layout.urlBarCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var siteNavigationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: self.views)
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
    
    private lazy var menuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [deleteButton, contextMenuButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Buttons
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.cancelButtonTap)
            }
            .store(in: &cancellables)
        cancelButton.setImage(.cancel, for: .normal)
        cancelButton.tintColor = .label
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        cancelButton.accessibilityIdentifier = "URLBar.cancelButton"
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 24),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return cancelButton
    }()
    
    lazy var contextMenuButton: UIButton = {
        let contextMenuButton = UIButton(type: .system)
        let publisher: UIControlPublisher<UIControl>
        if #available(iOS 14.0, *) {
            contextMenuButton.showsMenuAsPrimaryAction = true
            contextMenuButton.menu = UIMenu(children: [])
            publisher = contextMenuButton.publisher(event: .menuActionTriggered)
        } else {
            publisher = contextMenuButton.publisher(event: .touchUpInside)
        }
        publisher
            .sink { [unowned self] _ in
                self.viewModel.viewActionSubject.send(.contextMenuTap)
            }
            .store(in: &cancellables)
        contextMenuButton.setImage(.menu, for: .normal)
        contextMenuButton.tintColor = .label
        contextMenuButton.accessibilityLabel = UIConstants.strings.browserSettings
        contextMenuButton.accessibilityIdentifier = "HomeView.settingsButton"
        contextMenuButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        contextMenuButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        contextMenuButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            contextMenuButton.widthAnchor.constraint(equalToConstant: 24),
            contextMenuButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return contextMenuButton
    }()
    
    // TODO: make shield icon a button
    lazy var shieldIconButton: UIButton = {
        let shieldIcon = UIButton()
        shieldIcon
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.shieldIconTap)
            }
            .store(in: &cancellables)
        shieldIcon.setImage(.trackingProtectionOn, for: .normal)
        shieldIcon.contentMode = .center
        shieldIcon.accessibilityIdentifier = "URLBar.trackingProtectionIcon"
        shieldIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        shieldIcon.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            shieldIcon.widthAnchor.constraint(equalToConstant: 36),
            shieldIcon.heightAnchor.constraint(equalToConstant: 44),
        ])
        return shieldIcon
    }()
    
    lazy var backButton: UIButton = {
        let backButton =  UIButton(type: .system)
        backButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.backButtonTap)
            }
            .store(in: &cancellables)
        backButton.setImage(.back, for: .normal)
        backButton.tintColor = .label
        backButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
//        backButton.accessibilityLabel = UIConstants.strings.browserBack
//        backButton.isEnabled = false
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        backButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return backButton
    }()
    
    lazy var forwardButton: UIButton = {
        let forwardButton =  UIButton(type: .system)
        forwardButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.forwardButtonTap)
            }
            .store(in: &cancellables)
        forwardButton.setImage(.forward, for: .normal)
        forwardButton.tintColor = .label
        forwardButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
//        forwardButton.accessibilityLabel = UIConstants.strings.browserForward
//        forwardButton.isEnabled = false
        NSLayoutConstraint.activate([
            forwardButton.widthAnchor.constraint(equalToConstant: 44),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),
        ])
//        forwardButton.setContentCompressionResistancePriority(.required, for: .horizontal)
//        forwardButton.setContentHuggingPriority(.required, for: .horizontal)
        return forwardButton
    }()
    
    private lazy var stopReloadButton: UIButton = {
        let stopReloadButton =  UIButton(type: .system)
        stopReloadButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.stopReloadButtonTap)
            }
            .store(in: &cancellables)
        stopReloadButton.setImage(.refresh, for: .normal)
        stopReloadButton.tintColor = .label
        stopReloadButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        stopReloadButton.accessibilityIdentifier = "BrowserToolset.stopReloadButton"
        stopReloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        stopReloadButton.setContentHuggingPriority(.required, for: .horizontal)
        return stopReloadButton
    }()

    lazy var deleteButton: UIButton = {
        let deleteButton =  UIButton(type: .system)
        deleteButton
            .publisher(event: .touchUpInside)
            .sink { [unowned self] _ in
                self.viewModel
                    .viewActionSubject
                    .send(.deleteButtonTap)
            }
            .store(in: &cancellables)
        deleteButton.setImage(.delete, for: .normal)
        deleteButton.tintColor = .label
        deleteButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        deleteButton.accessibilityIdentifier = "URLBar.deleteButton"
//        deleteButton.isEnabled = false
        deleteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return deleteButton
    }()
    
    lazy var urlTextField: URLTextField = {
        let urlText = URLTextField()
        urlText.font = .body15
        urlText.tintColor = .primaryText
        urlText.textColor = .primaryText
        urlText.highlightColor = .accent.withAlphaComponent(0.4)
        urlText.keyboardType = .webSearch
        urlText.autocapitalizationType = .none
        urlText.autocorrectionType = .no
//        urlText.rightView = clearButton
        
        //TODO: check how we can tint the clear button, previosly it had a dark tint
        urlText.rightViewMode = .whileEditing
        urlText.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .vertical)
        urlText.autocompleteDelegate = self
        urlText.completionSource = domainCompletion
        urlText.accessibilityIdentifier = "URLBar.urlText"
        urlText.placeholder = UIConstants.strings.urlTextPlaceholder
        return urlText
    }()
    
    private let domainCompletion = DomainCompletion(completionSources: [TopDomainsCompletionSource(), CustomCompletionSource()])
    
    public var viewModel: URLBarViewModel = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    fileprivate func showBottomBar() {
        addSubview(bottomBackgroundView)
        bottomBackgroundView.addSubview(bottomStackView)
        
        
        NSLayoutConstraint.activate([
            
            bottomBackgroundView.topAnchor.constraint(equalTo: bottomStackView.topAnchor),
            bottomBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomStackView.heightAnchor.constraint(equalToConstant: 44),
            bottomStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    private func setupView() {
        viewModel.currentSelectionPublisher
            .dropFirst()
            .removeDuplicates(by: ==)
            .sink(receiveValue: self.adaptUI)
            .store(in: &cancellables)
       
        viewModel.statePublisher
            .removeDuplicates(by: ==)
            .sink(receiveValue: self.adaptUI)
            .store(in: &cancellables)
        
        viewModel
            .connectionStatePublisher
            .removeDuplicates(by: ==)
            .map { trackingProtectionStatus -> UIImage in
                switch trackingProtectionStatus {
                case .on:
                    return .trackingProtectionOn
                case .off:
                    return .trackingProtectionOff
                case .connectionNotSecure:
                    return .connectionNotSecure
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
        
        addSubview(topBackgroundView)
        addSubview(urlBarBackgroundView)
        addSubview(stackView)
        setupLayout()
    }
    
    private lazy var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .foundation
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .foundation
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [forwardButton, backButton, deleteButton, contextMenuButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupLayout() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            urlStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6).isActive = true
            urlStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }
        
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            topBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBackgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            //
            //pin urlBarBackgroundView to stackView
            urlBarBackgroundView.topAnchor.constraint(equalTo: urlStackView.topAnchor),
            urlBarBackgroundView.leadingAnchor.constraint(equalTo: urlStackView.leadingAnchor),
            urlBarBackgroundView.trailingAnchor.constraint(equalTo: urlStackView.trailingAnchor),
            urlBarBackgroundView.bottomAnchor.constraint(equalTo: urlStackView.bottomAnchor),
            
            
            stackView.heightAnchor.constraint(equalToConstant: 44),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

        ])
    }
}

private extension URLBarView {
    func transitionStopReloadButton(to loadingState: URLBarViewModel.BrowsingState.LoadingState) {
        UIView.transition(with: stopReloadButton, duration: 0.05, options: .transitionCrossDissolve, animations: {
            self.stopReloadButton.setImage(loadingState == .refresh ? .refresh : .stopRefresh, for: .normal)
        })
    }
    
    func adaptUI(
        for browsingState: URLBarViewModel.BrowsingState,
        device: URLBarViewModel.Device,
        orientation: URLBarViewModel.Orientation
    ) {
        switch (browsingState, device, orientation) {
        case (.home, .iPhone, .portrait), (.home, .iPhone, .landscape):
            menuStackView
                .animateShow(
                    firstDo: { [deleteButton, stackView, menuStackView] in
                        deleteButton.animateHideFromSuperview()
                        stackView.appendArrangedSubview(menuStackView)
                    }
                )
            
            stopReloadButton.animateHideFromSuperview()
            siteNavigationStackView.animateHideFromSuperview()
            
        case (.browsing(let loadingState), .iPhone, .portrait):
            siteNavigationStackView.animateHideFromSuperview()
            
            stopReloadButton
                .animateShow(
                    firstDo: { [urlStackView, stopReloadButton] in
                        urlStackView.appendArrangedSubview(stopReloadButton)
                    }, thenDo: {
                        self.transitionStopReloadButton(to: loadingState)
                    })
            
            menuStackView.animateHideFromSuperview()
            
        case (.browsing(let loadingState), .iPhone, .landscape):
            siteNavigationStackView
                .animateShow(
                    firstDo: { [stackView, siteNavigationStackView] in
                        stackView.prependArrangedSubview(siteNavigationStackView)
                    }
                )
            
            menuStackView
                .animateShow(
                    firstDo: { [deleteButton, menuStackView, stackView] in
                        deleteButton
                            .animateShow(firstDo: { menuStackView.prependArrangedSubview(deleteButton) })
                        stackView.appendArrangedSubview(menuStackView)
                    },
                    thenDo: { [stopReloadButton, urlStackView] in
                        stopReloadButton.setImage(loadingState == .refresh ? .refresh : .stopRefresh, for: .normal)
                        stopReloadButton
                            .animateShow(firstDo: {urlStackView.appendArrangedSubview(stopReloadButton) })
                    })
            
        case (.home, .iPad, _):
            siteNavigationStackView.animateHideFromSuperview()
            stopReloadButton.animateHideFromSuperview()
            deleteButton.animateHide()
            
        case (.browsing(let loadingState), .iPad, _):
            siteNavigationStackView
                .animateShow(
                    firstDo: { [stackView, siteNavigationStackView] in
                        stackView.prependArrangedSubview(siteNavigationStackView)
                    })
            stopReloadButton.setImage(loadingState == .refresh ? .refresh : .stopRefresh, for: .normal)
            stopReloadButton
                .animateShow(
                    firstDo: { [urlStackView, stopReloadButton] in
                        urlStackView.appendArrangedSubview(stopReloadButton)
                    })
            deleteButton.animateShow()
        }
    }
    
    func adaptUI(for selection: URLBarViewModel.Selection) {
        switch selection {
        case .selected:
            cancelButton
                .animateShow(
                    firstDo: { [stackView, urlStackView, cancelButton] in
                        guard
                            let index = stackView.arrangedSubviews.firstIndex(of: urlStackView)
                        else { return }
                        
                        stackView.insertArrangedSubview(cancelButton, at: index)
                    }
                )
            
            shieldIconButton.animateHide(thenDo: { [urlTextField] in urlTextField.becomeFirstResponder() })
            
        case .unselected:
            urlTextField.resignFirstResponder()
            cancelButton.animateHideFromSuperview()
            shieldIconButton.animateShow()
        }
    }
}


extension URLBarView: AutocompleteTextFieldDelegate {
    
    public func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        
        viewModel
            .viewActionSubject
            .send(.urlBarSelected)
        
        return true
    }
    
    public func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        viewModel
            .viewActionSubject
            .send(.urlBarDismissed)
        
        return true
    }
    
    public func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didTextChange text: String) {
        
    }
}

// MARK: SwiftUI Preview

struct BackgroundViewContainer: UIViewRepresentable {
    var state: URLBarViewModel.BrowsingState = .home
    
    func makeUIView(context: Context) -> URLBarView {
        let bar = URLBarView(frame: .zero)
//        bar.subject.send(state)
        return bar
    }
    func updateUIView(_ uiView: URLBarView, context: Context) {
        uiView.viewModel.goHome()
    }
}

public struct URLBarContainerView: View {
    @State private var state: URLBarViewModel.BrowsingState = .home
    
    public init() { }
    
    public var body: some View {
        ZStack {
            VStack {
                BackgroundViewContainer(state: state)
                    .frame(height: 200)
                    .background(Color.purple)
                Spacer()
                HStack {
                    Button("Home") { state = .home }
                    Button("Browsing") { state = .browsing(.stop) }
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


struct BackgroundViewContainer_Previews: PreviewProvider {
    static var previews: some View {
//        BackgroundViewContainerPreviewContainer()
//        BackgroundViewContainerPreviewContainer()
//            .previewDevice("iPad mini (6th generation)")
        if #available(iOS 15.0, *) {
            URLBarContainerView()
//                .previewInterfaceOrientation(.landscapeLeft)

//            URLBarContainerView()
//                .previewDevice("iPad mini (6th generation)")
//                .previewInterfaceOrientation(.landscapeLeft)
        }
        
        
    }
}
