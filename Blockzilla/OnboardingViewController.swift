/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Telemetry
import SwiftUI

class OnboardingViewController: UIViewController {
    
    private let textColor: UIColor = .label
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    //MARK: Mozilla Icon
    
    private lazy var mozillaIconImageView: UIImageView = {
        let image = UIImage(named: "icon_mozilla")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "OnboardingViewController.mozillaIconImageView"
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    //MARK: Title Labels
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(format: .onboardingTitle, AppInfo.config.productName)
        label.font = .title20Bold
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.welcomeLabel"
        return label
    }()
    
    private lazy var subWelcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingSubtitle
        label.font = .footnote14
        label.textColor = .secondaryText
        label.numberOfLines = 1
        label.accessibilityIdentifier = "OnboardingViewController.subWelcomeLabel"
        return label
    }()
    
    //MARK: Incognito
    
    private lazy var incognitoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingIncognitoTitle
        label.font = .footnote14Bold
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.incognitoTitleLabel"
        return label
    }()
    
    private lazy var incognitoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingIncognitoDescription
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .secondaryText
        label.accessibilityIdentifier = "OnboardingViewController.incognitoDescriptionLabel"
        return label
    }()
    
    private lazy var incognitoImageView: UIImageView = {
        let image = UIImage(named: "icon_private_mode")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "OnboardingViewController.incognitoImageView"
        return imageView
    }()
    
    //MARK: History
    
    private lazy var historyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingHistoryTitle
        label.font = .footnote14Bold
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.historyTitleLabel"
        return label
    }()
    
    private lazy var historyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingHistoryDescription
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .secondaryText
        label.accessibilityIdentifier = "OnboardingViewController.historyDescriptionLabel"
        return label
    }()
    
    private lazy var historyImageView: UIImageView = {
        let image = UIImage(named: "icon_history")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "OnboardingViewController.historyImageView"
        return imageView
    }()
    
    //MARK: Protection
    
    private lazy var protectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingProtectionTitle
        label.font = .footnote14Bold
        label.textColor = .primaryText
        label.accessibilityIdentifier = "OnboardingViewController.protectionTitleLabel"
        return label
    }()
    
    private lazy var protectionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .onboardingProtectionDescription
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .secondaryText
        label.accessibilityIdentifier = "OnboardingViewController.protectionDescriptionLabel"
        return label
    }()
    
    private lazy var protectionImageView: UIImageView = {
        let image = UIImage(named: "icon_settings")
        let imageView = UIImageView(image: image)
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
        button.setTitle(.onboardingButtonTitle, for: .normal)
        button.titleLabel?.font = .footnote14
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.accessibilityIdentifier = "IntroViewController.startBrowsingButton"
        button.addTarget(self, action: #selector(IntroViewController.didTapStartButton), for: .touchUpInside)
        return button
    }()

    // MARK: - StackViews
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topStackView, subWelcomeLabel, middleStackView, startBrowsingButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = UIConstants.layout.onboardingMainStackViewSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 50, left: 20, bottom: 50, right: 20)
        stackView.accessibilityIdentifier = "OnboardingViewController.mainStackView"
        return stackView
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mozillaIconImageView, welcomeLabel])
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
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = UIConstants.layout.onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.middleStackView"
        return stackView
    }()
    
    private lazy var incognitoTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoTitleLabel, incognitoDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = UIConstants.layout.onboardingTextStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.incognitoTextStackView"
        return stackView
    }()
    
    private lazy var incognitoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoImageView, incognitoTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = UIConstants.layout.onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.incognitoStackView"
        return stackView
    }()
    
    private lazy var historyTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [historyTitleLabel, historyDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = UIConstants.layout.onboardingTextStackViewSpacing
        stackView.distribution = .fillProportionally
        stackView.accessibilityIdentifier = "OnboardingViewController.historyTextStackView"
        return stackView
    }()
    
    private lazy var historyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [historyImageView, historyTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = UIConstants.layout.onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.historyStackView"
        return stackView
    }()
    
    private lazy var protectionTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [protectionTitleLabel, protectionDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = UIConstants.layout.onboardingTextStackViewSpacing
        stackView.distribution = .fillProportionally
        stackView.accessibilityIdentifier = "OnboardingViewController.protectionTextStackView"
        return stackView
    }()
    
    private lazy var protectionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [protectionImageView, protectionTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = UIConstants.layout.onboardingMiddleStackViewSpacing
        stackView.accessibilityIdentifier = "OnboardingViewController.protectionStackView"
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIDevice.current.orientation.isLandscape {
                mainStackView.snp.remakeConstraints { make in
                    make.centerX.equalTo(scrollView.snp.centerX)
                    make.width.equalTo(scrollView.snp.width)
                    make.top.greaterThanOrEqualToSuperview()
                    make.bottom.lessThanOrEqualToSuperview()
                }
            } else {
                mainStackView.snp.remakeConstraints { make in
                    make.centerX.equalTo(scrollView.snp.centerX)
                    make.centerY.equalTo(scrollView.snp.centerY)
                    make.width.equalTo(scrollView.snp.width).multipliedBy(0.9)
                    make.top.greaterThanOrEqualToSuperview()
                    make.bottom.lessThanOrEqualToSuperview()
                }
            }
        }
    }
    
    func addSubViews() {
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView.snp.centerX)
            make.centerY.equalTo(scrollView.snp.centerY)
            make.width.equalTo(scrollView.snp.width).multipliedBy(0.9)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        view.backgroundColor = .systemBackground

        mozillaIconImageView.snp.makeConstraints { $0.width.height.equalTo(60) }
        
        incognitoImageView.snp.makeConstraints { $0.width.height.equalTo(UIConstants.layout.onboardingIconsWidthHeight) }
        historyImageView.snp.makeConstraints { $0.width.height.equalTo(UIConstants.layout.onboardingIconsWidthHeight) }
        protectionImageView.snp.makeConstraints { $0.width.height.equalTo(UIConstants.layout.onboardingIconsWidthHeight) }
        
        startBrowsingButton.snp.makeConstraints { make in
            make.width.equalTo(UIConstants.layout.onboardingButtonWidth)
            make.height.equalTo(UIConstants.layout.onboardingButtonHeight)
        }
    }

    @objc func didTapStartButton() {
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.click, object: TelemetryEventObject.onboarding, value: "finish")
        dismiss(animated: true, completion: nil)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (UIDevice.current.userInterfaceIdiom == .phone) ? .portrait : .allButUpsideDown
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

fileprivate extension String {
    
    static let onboardingTitle = NSLocalizedString("Onboarding.Title", value: "Welcome to Firefox %@!", comment: "Text for a label that indicates the title for onboarding screen. (Focus and Klar)")
    static let onboardingSubtitle = NSLocalizedString("Onboarding.Subtitle", value: "Take your private browsing to the next level.", comment: "Text for a label that indicates the subtitle for onboarding screen.")
    static let onboardingIncognitoTitle = NSLocalizedString("Onboarding.Incognito.Title", value: "More than just incognito", comment: "Text for a label that indicates the title of incognito section from onboarding screen.")
    static let onboardingIncognitoDescription = NSLocalizedString("Onboarding.Incognito.Description", value: "Focus is a dedicated privacy browser with tracking protection and content blocking.", comment: "Text for a label that indicates the description of incognito section from onboarding screen.")
    static let onboardingHistoryTitle = NSLocalizedString("Onboarding.History.Title", value: "Your history doesn’t follow you.", comment: "Text for a label that indicates the title of history section from onboarding screen.")
    static let onboardingHistoryDescription = NSLocalizedString("Onboarding.History.Description", value: "Erase your browsing history, passwords, bookmarks, cookies, and prevent unwanted ads from following you in a simple click!", comment: "Text for a label that indicates the description of history section from onboarding screen.")
    static let onboardingProtectionTitle = NSLocalizedString("Onboarding.Protection.Title", value: "Protection at your own discretion", comment: "Text for a label that indicates the title of protection section from onboarding screen.")
    static let onboardingProtectionDescription = NSLocalizedString("Onboarding.Protection.Description", value: "Configure settings so you can decide how much or how little you share.", comment: "Text for a label that indicates the description of protection section from onboarding screen.")
    static let onboardingButtonTitle = NSLocalizedString("Onboarding.Button.Title", value: "Start browsing", comment: "Text for a label that indicates the title of button from onboarding screen")
}
