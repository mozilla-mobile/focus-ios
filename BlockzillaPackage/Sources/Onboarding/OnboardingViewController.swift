/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import DesignSystem

public class OnboardingViewController: UIViewController {
    
    public init(
        config: TextConfig,
        dismissOnboardingScreen: @escaping (() -> Void)
    ) {
        self.config = config
        self.dismissOnboardingScreen = dismissOnboardingScreen
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("OnboardingViewController hasn't implemented init?(coder:)")
    }
    
    private let dismissOnboardingScreen: (() -> Void)
    private let config: TextConfig
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    //MARK: Mozilla Icon
    
    private lazy var mozillaIconImageView: UIImageView = {
        let imageView = UIImageView(image: .mozilla)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "OnboardingViewController.mozillaIconImageView"
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: Title Labels
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.welcomeText
        label.font = .title20Bold
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.welcomeLabel"
        return label
    }()
    
    private lazy var subWelcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingSubtitle
        label.font = .footnote14
        label.textColor = .secondaryText
        label.numberOfLines = 0
        label.accessibilityIdentifier = "OnboardingViewController.subWelcomeLabel"
        return label
    }()
    
    //MARK: Incognito
    
    private lazy var incognitoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingIncognitoTitle
        label.numberOfLines = 0
        label.font = .footnote14Bold
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.incognitoTitleLabel"
        return label
    }()
    
    private lazy var incognitoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingIncognitoDescription
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .secondaryText
        label.accessibilityIdentifier = "OnboardingViewController.incognitoDescriptionLabel"
        return label
    }()
    
    private lazy var incognitoImageView: UIImageView = {
        let imageView = UIImageView(image: .privateMode)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "OnboardingViewController.incognitoImageView"
        return imageView
    }()
    
    //MARK: History
    
    private lazy var historyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingHistoryTitle
        label.font = .footnote14Bold
        label.numberOfLines = 0
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.historyTitleLabel"
        return label
    }()
    
    private lazy var historyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingHistoryDescription
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .secondaryText
        label.accessibilityIdentifier = "OnboardingViewController.historyDescriptionLabel"
        return label
    }()
    
    private lazy var historyImageView: UIImageView = {
        let imageView = UIImageView(image: .history)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "OnboardingViewController.historyImageView"
        return imageView
    }()
    
    //MARK: Protection
    
    private lazy var protectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingProtectionTitle
        label.font = .footnote14Bold
        label.textColor = .primaryText
        label.numberOfLines = 0
        label.accessibilityIdentifier = "OnboardingViewController.protectionTitleLabel"
        return label
    }()
    
    private lazy var protectionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = config.onboardingProtectionDescription
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .secondaryText
        label.accessibilityIdentifier = "OnboardingViewController.protectionDescriptionLabel"
        return label
    }()
    
    private lazy var protectionImageView: UIImageView = {
        let imageView = UIImageView(image: .settings)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "OnboardingViewController.protectionImageView"
        return imageView
    }()
    
    //MARK: Start Browsing Button
    
    private lazy var startBrowsingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primaryButton
        button.setTitle(config.onboardingButtonTitle, for: .normal)
        button.titleLabel?.font = .footnote14
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.accessibilityIdentifier = "IntroViewController.startBrowsingButton"
        button.addTarget(self, action: #selector(OnboardingViewController.didTapStartButton), for: .touchUpInside)
        return button
    }()

    // MARK: - StackViews
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topStackView, middleStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            stackView.layoutMargins = .init(top: view.frame.height / .onboardingLayoutMarginTopDivider, left: view.frame.width / .onboardingLayoutMarginLeadingTrailingDivider, bottom: .onboardingLayoutMarginBottom, right: view.frame.width / .onboardingLayoutMarginLeadingTrailingDivider)
            stackView.spacing = view.frame.height / .onboardingSpacingDividerPhone
        } else {
            stackView.layoutMargins = .init(top: .onboardingLayoutMarginTop, left: view.frame.width / .onboardingLayoutMarginLeadingTrailingDivider, bottom: .onboardingLayoutMarginBottom, right: view.frame.width / .onboardingLayoutMarginLeadingTrailingDivider)
            stackView.spacing = view.frame.height / .onboardingSpacingDividerPad
        }
        stackView.accessibilityIdentifier = "OnboardingViewController.mainStackView"
        return stackView
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mozillaIconImageView, welcomeLabel, subWelcomeLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.accessibilityIdentifier = "OnboardingViewController.topStackView"
        return stackView
    }()
    
    private lazy var middleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoStackView, historyStackView, protectionStackView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = .onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.middleStackView"
        return stackView
    }()
    
    private lazy var incognitoTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoTitleLabel, incognitoDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = .onboardingTextStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.incognitoTextStackView"
        return stackView
    }()
    
    private lazy var incognitoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoImageView, incognitoTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = .onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.incognitoStackView"
        return stackView
    }()
    
    private lazy var historyTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [historyTitleLabel, historyDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = .onboardingTextStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.historyTextStackView"
        return stackView
    }()
    
    private lazy var historyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [historyImageView, historyTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = .onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.historyStackView"
        return stackView
    }()
    
    private lazy var protectionTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [protectionTitleLabel, protectionDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = .onboardingTextStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.protectionTextStackView"
        return stackView
    }()
    
    private lazy var protectionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [protectionImageView, protectionTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = .onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.protectionStackView"
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            mainStackView.layoutMargins = .init(top: size.height / .onboardingLayoutMarginTopDivider, left: size.width / .onboardingLayoutMarginLeadingTrailingDivider, bottom: .onboardingLayoutMarginBottom, right: size.width / .onboardingLayoutMarginLeadingTrailingDivider)
            mainStackView.spacing = size.height / .onboardingSpacingDividerPhone
        } else {
            mainStackView.layoutMargins = .init(top: .onboardingLayoutMarginTop, left: size.width / .onboardingLayoutMarginLeadingTrailingDivider, bottom: .onboardingLayoutMarginBottom, right: size.width / .onboardingLayoutMarginLeadingTrailingDivider)
            mainStackView.spacing = size.height / .onboardingSpacingDividerPad
        }
        
        startBrowsingButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(size.height / .onboardingButtonButtomInsetDivider)
            make.leading.trailing.equalToSuperview().inset(size.width / .onboardingButtonLeadingTrailingInsetDivider)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
    }
    
    func addSubViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.width.equalTo(view)
        }

        mozillaIconImageView.snp.makeConstraints { $0.width.height.equalTo(60) }
        
        incognitoImageView.snp.makeConstraints { $0.width.height.equalTo(CGFloat.onboardingIconsWidthHeight) }
        historyImageView.snp.makeConstraints { $0.width.height.equalTo(CGFloat.onboardingIconsWidthHeight) }
        protectionImageView.snp.makeConstraints { $0.width.height.equalTo(CGFloat.onboardingIconsWidthHeight) }
        
        view.addSubview(startBrowsingButton)
        startBrowsingButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(view.frame.height / .onboardingButtonButtomInsetDivider)
            make.leading.trailing.equalToSuperview().inset(view.frame.width / .onboardingButtonLeadingTrailingInsetDivider)
            make.top.equalTo(scrollView.snp.bottom).inset(-20)
        }
    }

    @objc func didTapStartButton() {
        dismissOnboardingScreen()
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (UIDevice.current.userInterfaceIdiom == .phone) ? .portrait : .allButUpsideDown
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

fileprivate extension CGFloat {
    static let onboardingButtonHeight: CGFloat = 44
    static let onboardingIconsWidthHeight: CGFloat = 20
    static let onboardingTextStackViewSpacing: CGFloat = 6
    static let onboardingMiddleStackViewSpacing: CGFloat = 24
    static let onboardingSpacingDividerPhone: CGFloat = 15
    static let onboardingSpacingDividerPad: CGFloat = 28
    static let onboardingLayoutMarginTopDivider: CGFloat = 10
    static let onboardingLayoutMarginTop: CGFloat = 50
    static let onboardingLayoutMarginLeadingTrailingDivider: CGFloat = 10
    static let onboardingLayoutMarginBottom: CGFloat = 0
    static let onboardingButtonButtomInsetDivider: CGFloat = 20
    static let onboardingButtonLeadingTrailingInsetDivider: CGFloat = 5
}

public struct TextConfig {
    let welcomeText: String
    let onboardingTitle: String
    let onboardingSubtitle: String
    let onboardingIncognitoTitle: String
    let onboardingIncognitoDescription: String
    let onboardingHistoryTitle: String
    let onboardingHistoryDescription: String
    let onboardingProtectionTitle: String
    let onboardingProtectionDescription: String
    let onboardingButtonTitle: String
    
    public init(
        welcomeText: String,
        onboardingTitle: String,
        onboardingSubtitle: String,
        onboardingIncognitoTitle: String,
        onboardingIncognitoDescription: String,
        onboardingHistoryTitle: String,
        onboardingHistoryDescription: String,
        onboardingProtectionTitle: String,
        onboardingProtectionDescription: String,
        onboardingButtonTitle: String
    ) {
        self.welcomeText = welcomeText
        self.onboardingTitle = onboardingTitle
        self.onboardingSubtitle = onboardingSubtitle
        self.onboardingIncognitoTitle = onboardingIncognitoTitle
        self.onboardingIncognitoDescription = onboardingIncognitoDescription
        self.onboardingHistoryTitle = onboardingHistoryTitle
        self.onboardingHistoryDescription = onboardingHistoryDescription
        self.onboardingProtectionTitle = onboardingProtectionTitle
        self.onboardingProtectionDescription = onboardingProtectionDescription
        self.onboardingButtonTitle = onboardingButtonTitle
        
    }
    
}
