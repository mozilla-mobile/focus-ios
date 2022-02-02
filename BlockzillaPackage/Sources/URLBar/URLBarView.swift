import UIKit
import SwiftUI
import SnapKit
import Combine
import UIHelpers
import DesignSystem

typealias UISpacer = UIView

public class URLBarView: UIView {
    
    public enum BrowsingState: Equatable {
        case home
        case browsing
    }
    
    public enum Orientation: Equatable {
        case portrait
        case landscape
        
        init() {
            self = UIApplication.shared.orientation?.isPortrait ?? true ? .portrait : .landscape
        }
    }
    
    public enum Selection: Equatable {
        case selected
        case unselected
    }
    
    public enum Device: Equatable {
        case iPhone
        case iPad
        
        init() {
            self = UIDevice.current.userInterfaceIdiom == .phone ? .iPhone : .iPad
        }
    }
    
    
    @Published var currentSelection = Selection.selected
    @Published public var browsingState = BrowsingState.home
    
    private let leftSpacer = UISpacer()
    private let rightSpacer = UISpacer()
    
    func adaptUI(for browsingState: BrowsingState, device: Device = .init(), orientation: Orientation = .init()) {
        switch (browsingState, device, orientation) {
        case (.home, .iPhone, .portrait), (.home, .iPhone, .landscape):
            menuStackView.animateShow(firstDo: {
                self.deleteButton.animateHideFromSuperview()
                self.stackView.appendArrangedSubview(self.menuStackView)
            })
            
            stopReloadButton.animateHideFromSuperview()
            siteNavigationStackView.animateHideFromSuperview()
           
        case (.browsing, .iPhone, .portrait):
            siteNavigationStackView.animateHideFromSuperview()
            
            stopReloadButton.animateShow(firstDo: {
                self.urlStackView.appendArrangedSubview(self.stopReloadButton)
            })

            menuStackView.animateHideFromSuperview()
            
        case (.browsing, .iPhone, .landscape):
            siteNavigationStackView.animateShow(firstDo: {
                self.stackView.prependArrangedSubview(self.siteNavigationStackView)
            })
            
            menuStackView.animateShow {
                self.deleteButton.animateShow(firstDo: {
                    self.menuStackView.prependArrangedSubview(self.deleteButton)
                })
                self.stackView.appendArrangedSubview(self.menuStackView)
            } thenDo: {
                self.stopReloadButton.animateShow(firstDo: {
                    self.urlStackView.appendArrangedSubview(self.stopReloadButton)
                })
            }
            
        case (.home, .iPad, _):
            siteNavigationStackView.animateHideFromSuperview()
            stopReloadButton.animateHideFromSuperview()
            deleteButton.animateHide()
            
        case (.browsing, .iPad, _):
            siteNavigationStackView.animateShow(firstDo: {
                self.stackView.prependArrangedSubview(self.siteNavigationStackView)
            })
            stopReloadButton.animateShow(firstDo: {
                self.urlStackView.appendArrangedSubview(self.stopReloadButton)
            })
            deleteButton.animateShow()
        }
    }
    
    func adaptUI(for selection: Selection) {
        switch selection {
        case .selected:
            self.cancelButton.animateShow(firstDo: {
                guard
                    let index = self.stackView.arrangedSubviews.firstIndex(of: self.urlStackView)
                else { return }
                
                self.stackView.insertArrangedSubview(self.cancelButton, at: index)
            })
            
            self.shieldIcon.animateHide(thenDo:  {
                self.urlTextField.becomeFirstResponder()
            })
            
            
        case .unselected:
            self.urlTextField.resignFirstResponder()
            self.cancelButton.animateHideFromSuperview()
            self.shieldIcon.animateShow()
        }
    }
    
    var views: [UIView] {
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
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: self.views)
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var urlStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                shieldIcon,
                urlTextField,
                stopReloadButton
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
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setImage(.cancel, for: .normal)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        cancelButton.accessibilityIdentifier = "URLBar.cancelButton"
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 24),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return cancelButton
    }()
    
    lazy var contextMenuButton: UIButton = {
        let contextMenuButton = UIButton()
        contextMenuButton.tintColor = .primaryText
        if #available(iOS 14.0, *) {
            contextMenuButton.showsMenuAsPrimaryAction = true
            contextMenuButton.menu = UIMenu(children: [])
//            contextMenuButton.addTarget(self, action: #selector(didPressContextMenu), for: .menuActionTriggered)
        } else {
//            contextMenuButton.addTarget(self, action: #selector(didPressContextMenu), for: .touchUpInside)
        }
        contextMenuButton.setImage(.menu, for: .normal)
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
    
    
    lazy var urlBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .locationBar
        view.layer.cornerRadius = UIConstants.layout.urlBarCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var shieldIcon: TrackingProtectionBadge = {
        let shieldIcon = TrackingProtectionBadge()
        shieldIcon.tintColor = .primaryText
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
    
    
    lazy var siteNavigationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var menuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [deleteButton, contextMenuButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.setImage(.back, for: .normal)
//        backButton.addTarget(self, action: #selector(didPressBack), for: .touchUpInside)
        backButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
//        backButton.accessibilityLabel = UIConstants.strings.browserBack
        backButton.isEnabled = false
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        backButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        return backButton
    }()
    
    lazy var forwardButton: UIButton = {
        let forwardButton = UIButton()
        forwardButton.setImage(.forward, for: .normal)
//        forwardButton.addTarget(self, action: #selector(didPressForward), for: .touchUpInside)
        forwardButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
//        forwardButton.accessibilityLabel = UIConstants.strings.browserForward
        forwardButton.isEnabled = false
        NSLayoutConstraint.activate([
            forwardButton.widthAnchor.constraint(equalToConstant: 44),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),
        ])
//        forwardButton.setContentCompressionResistancePriority(.required, for: .horizontal)
//        forwardButton.setContentHuggingPriority(.required, for: .horizontal)
        return forwardButton
    }()
    
    lazy var stopReloadButton: UIButton = {
        let stopReloadButton = UIButton()
        stopReloadButton.setImage(.refresh, for: .normal)
        stopReloadButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
//        stopReloadButton.addTarget(self, action: #selector(didPressStopReload), for: .touchUpInside)
        stopReloadButton.accessibilityIdentifier = "BrowserToolset.stopReloadButton"
        stopReloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        stopReloadButton.setContentHuggingPriority(.required, for: .horizontal)
        return stopReloadButton
    }()

    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setImage(.delete, for: .normal)
//        deleteButton.addTarget(self, action: #selector(didPressDelete), for: .touchUpInside)
        deleteButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        deleteButton.accessibilityIdentifier = "URLBar.deleteButton"
        deleteButton.isEnabled = false
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
        urlText.rightViewMode = .whileEditing
        urlText.setContentHuggingPriority(UILayoutPriority(rawValue: UIConstants.layout.urlBarLayoutPriorityRawValue), for: .vertical)
        urlText.autocompleteDelegate = self
        urlText.completionSource = domainCompletion
        urlText.accessibilityIdentifier = "URLBar.urlText"
        urlText.placeholder = UIConstants.strings.urlTextPlaceholder
        return urlText
    }()
    
    private let domainCompletion = DomainCompletion(completionSources: [TopDomainsCompletionSource(), CustomCompletionSource()])
    
    private var cancellable: AnyCancellable?
    private var cancellable2: AnyCancellable?
    private var cancellable3: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        let notificationSubject = NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification, object: nil)
        
        cancellable = Publishers.CombineLatest($browsingState, notificationSubject)
            .receive(on: DispatchQueue.main)
            .map { (browsingState, _) in
                return (browsingState, Orientation())
            }
            .sink { newBrowsingState, orientation in
                self.adaptUI(for: newBrowsingState, orientation: orientation)
            }
        
        cancellable2 =  $currentSelection
            .sink { newSelection in
                guard newSelection != self.currentSelection else { return }
                self.adaptUI(for: newSelection)
            }
        
        adaptUI(for: browsingState)
        adaptUI(for: currentSelection)
        
        addSubview(urlBarBackgroundView)
        addSubview(stackView)
        setupLayout()
    }
    
    private func setupLayout() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            urlStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6).isActive = true
            urlStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }
        
        
        NSLayoutConstraint.activate([
            //
            //pin urlBarBackgroundView to stackView
            urlBarBackgroundView.topAnchor.constraint(equalTo: urlStackView.topAnchor),
            urlBarBackgroundView.leadingAnchor.constraint(equalTo: urlStackView.leadingAnchor),
            urlBarBackgroundView.trailingAnchor.constraint(equalTo: urlStackView.trailingAnchor),
            urlBarBackgroundView.bottomAnchor.constraint(equalTo: urlStackView.bottomAnchor),
            
            //layout stackView
            //            stackView.topAnchor.constraint(equalTo: topAnchor),
//            urlStackView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.heightAnchor.constraint(equalToConstant: 44),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

        ])
    }
    
    //custom views should override this to return true if
    //they cannot layout correctly using autoresizing.
    //from apple docs https://developer.apple.com/documentation/uikit/uiview/1622549-requiresconstraintbasedlayout
//    public override class var requiresConstraintBasedLayout: Bool {
//        return true
//    }
    
    @objc func cancelPressed() {
        currentSelection = .unselected
    }
}

extension URLBarView: AutocompleteTextFieldDelegate {
    
    public func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        
        currentSelection = .selected
        
        return true
    }
    
    public func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        cancelPressed()
        return true
    }
    
    public func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didTextChange text: String) {
//        userInputText = text
    }
}

// MARK: SwiftUI Preview

struct BackgroundViewContainer: UIViewRepresentable {
    var state: URLBarView.BrowsingState = .home
    
    func makeUIView(context: Context) -> URLBarView {
        let bar = URLBarView(frame: .zero)
//        bar.subject.send(state)
        return bar
    }
    func updateUIView(_ uiView: URLBarView, context: Context) {
        uiView.browsingState = state
    }
}

public struct URLBarContainerView: View {
    @State private var state: URLBarView.BrowsingState = .home
    
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
                    Button("Browsing") { state = .browsing }
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
