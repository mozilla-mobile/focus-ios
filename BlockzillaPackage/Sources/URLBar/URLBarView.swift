import UIKit
import SwiftUI
import SnapKit
import Combine

typealias UISpacer = UIView

extension UIApplication {
    var orientation : UIInterfaceOrientation? {
        UIApplication
            .shared
            .windows
            .first(where: { $0.isKeyWindow })?
            .windowScene?
            .interfaceOrientation
    }
}

extension UIView {
    func show() {
        self.isHidden = false
        self.alpha = 1
    }
    
    func hide() {
        self.isHidden = true
        self.alpha = 0
    }
}

public class URLBarView: UIView {
    
    public enum BrowsingState {
        case home
        case browsing
    }
    
    public enum Orientation {
        case portrait
        case landscape
    }
    
    public enum Selection {
        case selected
        case unselected
    }
    
    public let browsingSubject = CurrentValueSubject<BrowsingState, Never>(.home)
    public let selectionSubject = CurrentValueSubject<Selection, Never>(.selected)
    
    private let leftSpacer = UISpacer()
    private let rightSpacer = UISpacer()
    
    
    func adaptUI(for state: BrowsingState, selection: Selection) {
        let device: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        let orientation: Orientation = UIApplication.shared.orientation?.isPortrait ?? true ? .portrait : .landscape
        
        switch (state, device, orientation) {
        case (.home, .phone, _):
            siteNavigationStackView.hide()
            leftSpacer.hide()
            urlStackView.show()
            rightSpacer.hide()
            menuStackView.show()
            stopReloadButton.hide()
            contextMenuButton.show()
            deleteButton.hide()
           
        case (.browsing, .phone, .portrait):
            siteNavigationStackView.hide()
            leftSpacer.hide()
            urlStackView.show()
            rightSpacer.hide()
            stopReloadButton.show()
            
            menuStackView.hide()
            contextMenuButton.hide()
            deleteButton.hide()
            
        case (.browsing, .phone, .landscape):
            siteNavigationStackView.show()
            leftSpacer.hide()
            urlStackView.show()
            rightSpacer.hide()
            stopReloadButton.show()
            menuStackView.show()
            deleteButton.show()
            
        case (.home, .pad, _):
            siteNavigationStackView.hide()
            leftSpacer.show()
            urlStackView.show()
            rightSpacer.show()
            stopReloadButton.hide()
            menuStackView.show()
            deleteButton.hide()
            
        case (.browsing, .pad, _):
            siteNavigationStackView.show()
            leftSpacer.show()
            urlStackView.show()
            rightSpacer.hide()
            stopReloadButton.show()
            menuStackView.show()
            deleteButton.show()
            
        default: ()
        }
        
        switch selection {
        case .selected:
            self.cancelButton.show()
            self.shieldIcon.hide()
        case .unselected:
            self.cancelButton.hide()
            self.shieldIcon.show()
        }
//        stackView.setNeedsLayout()
//        stackView.layoutIfNeeded()
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                siteNavigationStackView,
                leftSpacer,
                cancelButton,
                urlStackView,
                rightSpacer,
                menuStackView
            ]
        )
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
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
//        cancelButton.isHidden = true
//        cancelButton.alpha = 0
        cancelButton.setImage(.cancel, for: .normal)
        cancelButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        cancelButton.accessibilityIdentifier = "URLBar.cancelButton"
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
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
        return shieldIcon
    }()
    
    
    lazy var siteNavigationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var menuStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [deleteButton, contextMenuButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
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
        return backButton
    }()
    
    lazy var forwardButton: UIButton = {
        let forwardButton = UIButton()
        forwardButton.setImage(.forward, for: .normal)
//        forwardButton.addTarget(self, action: #selector(didPressForward), for: .touchUpInside)
        forwardButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
//        forwardButton.accessibilityLabel = UIConstants.strings.browserForward
        forwardButton.isEnabled = false
        forwardButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        forwardButton.setContentHuggingPriority(.required, for: .horizontal)
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
        return deleteButton
    }()
    
    lazy var urlTextField: URLTextField = {
        let urlText = URLTextField()
//        urlText.font = .body15
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
//        urlText.completionSource = domainCompletion
        urlText.accessibilityIdentifier = "URLBar.urlText"
        urlText.placeholder = UIConstants.strings.urlTextPlaceholder
        return urlText
    }()
    
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
        
        cancellable = Publishers.CombineLatest3(browsingSubject, selectionSubject, notificationSubject)
            .receive(on: DispatchQueue.main)
            .sink { (browsingState, selection, _) in
//                UIView.animate(withDuration: 0.1) {
                    self.adaptUI(for: browsingState, selection: selection)
//                }
                
            }
        addSubview(urlBarBackgroundView)
        addSubview(stackView)
        setupLayout()
        selectionSubject.send(.unselected)
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
            
            
//            stackView.heightAnchor.constraint(equalToConstant: 50),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

        ])
    }
    
    //custom views should override this to return true if
    //they cannot layout correctly using autoresizing.
    //from apple docs https://developer.apple.com/documentation/uikit/uiview/1622549-requiresconstraintbasedlayout
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    @objc func cancelPressed() {
        selectionSubject.send(.unselected)
        self.urlTextField.resignFirstResponder()
    }
}

extension URLBarView: AutocompleteTextFieldDelegate {
    public func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        
//        setTextToURL(displayFullUrl: true)
//        autocompleteTextField.highlightAll()
//
//        if !isEditing {
//            isEditing = true
//            delegate?.urlBarDidActivate(self)
//        }
//
//        // When text.characters.count == 0, it is the HomeView
//        if let text = autocompleteTextField.text, !isEditing, text.count == 0 {
//            shouldPresent = true
//        }
        
        
        selectionSubject.send(.selected)
        
        return true
    }
    
    public func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        cancelPressed()
//        if let autocompleteText = autocompleteTextField.text, autocompleteText != userInputText {
//            Telemetry.default.recordEvent(TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.autofill))
//        }
//        userInputText = nil
//
//        delegate?.urlBar(self, didSubmitText: autocompleteTextField.text ?? "")
//
//        if Settings.getToggle(.enableSearchSuggestions) {
//            Telemetry.default.recordEvent(TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.searchSuggestionNotSelected))
//        }
//
        return true
    }
    
    public func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didTextChange text: String) {
//        userInputText = text
//
//        if !text.isEmpty {
//            displayClearButton(shouldDisplay: true, animated: true)
//        }
//
//        autocompleteTextField.rightView?.isHidden = text.isEmpty
//
//        if !isEditing && shouldPresent {
//            isEditing = true
//            delegate?.urlBarDidActivate(self)
//        }
//
//        delegate?.urlBar(self, didEnterText: text)
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
        uiView.browsingSubject.send(state)
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
                .previewInterfaceOrientation(.landscapeLeft)

            URLBarContainerView()
                .previewDevice("iPad mini (6th generation)")
                .previewInterfaceOrientation(.landscapeLeft)
        }
        
        
    }
}
