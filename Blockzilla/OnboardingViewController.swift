/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Telemetry

class OnboardingViewController: UIViewController {

    //MARK: Mozilla Icon
    
    private lazy var mozillaIconImageView: UIImageView = {
        let image = UIImage(named: "highlight")
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
        label.text = "Welcome to Firefox Focus!"
        label.font = .title20Bold
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.welcomeLabel"
        return label
    }()
    
    private lazy var subWelcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Take your private browsing to the next level."
        label.font = .footnote14
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.subWelcomeLabel"
        return label
    }()
    
    //MARK: Incognito
    
    private lazy var incognitoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "More than just incognito"
        label.font = .footnote14Bold
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.incognitoTitleLabel"
        return label
    }()
    
    private lazy var incognitoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Focus is a dedicated privacy browser with tracking protection and content blocking."
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.incognitoDescriptionLabel"
        return label
    }()
    
    private lazy var incognitoImageView: UIImageView = {
        let image = UIImage(named: "highlight") //UIImage(named: "IncognitoImage") //Asset not in app
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "OnboardingViewController.incognitoImageView"
        return imageView
    }()
    
    //MARK: History
    
    private lazy var historyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your history doesn’t follow you"
        label.font = .footnote14Bold
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.historyTitleLabel"
        return label
    }()
    
    private lazy var historyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Erase your browsing history, passwords, bookmarks, cookies, and prevent unwanted ads from following you in a simple click!"
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.historyDescriptionLabel"
        return label
    }()
    
    private lazy var historyImageView: UIImageView = {
        let image = UIImage(named: "highlight") //UIImage(named: "HistoryImage") //Asset not in app
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "OnboardingViewController.historyImageView"
        return imageView
    }()
    
    //MARK: Protection
    
    private lazy var protectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Protection at your own discretion"
        label.font = .footnote14Bold
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.protectionTitleLabel"
        return label
    }()
    
    private lazy var protectionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Configure settings so you can decide how much or how little you share."
        label.numberOfLines = 0
        label.font = .footnote14
        label.textColor = .darkGray
        label.accessibilityIdentifier = "OnboardingViewController.protectionDescriptionLabel"
        return label
    }()
    
    private lazy var protectionImageView: UIImageView = {
        let image = UIImage(named: "highlight")//UIImage(named: "ProtectionImage") //Asset not in app
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "OnboardingViewController.protectionImageView"
        return imageView
    }()
    
    //MARK: Start Browsing Button
    
    private lazy var startBrowsingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .secondaryButton
        button.setTitle("Start Browsing", for: .normal)
        button.titleLabel?.font = .footnote14
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
        stackView.spacing = 22
        stackView.isLayoutMarginsRelativeArrangement = true
//        stackView.layoutMargins = .init(top: 20, left: 10, bottom: 40, right: 10)
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
        stackView.spacing = 18
        stackView.accessibilityIdentifier = "OnboardingViewController.middleStackView"
        return stackView
    }()
    
    private lazy var incognitoTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoTitleLabel, incognitoDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.accessibilityIdentifier = "OnboardingViewController.incognitoTextStackView"
        return stackView
    }()
    
    private lazy var incognitoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [incognitoImageView, incognitoTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 18
        stackView.accessibilityIdentifier = "OnboardingViewController.incognitoStackView"
        return stackView
    }()
    
    private lazy var historyTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [historyTitleLabel, historyDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
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
        stackView.spacing = 18
        stackView.accessibilityIdentifier = "OnboardingViewController.historyStackView"
        return stackView
    }()
    
    private lazy var protectionTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [protectionTitleLabel, protectionDescriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
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
        stackView.spacing = 18
        stackView.accessibilityIdentifier = "OnboardingViewController.protectionStackView"
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        
    }
    
    func addSubViews() {
        view.addSubview(mainStackView)
        view.backgroundColor = .white
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.trailing.leading.equalToSuperview().inset(24)
        }

        mozillaIconImageView.snp.makeConstraints { $0.width.height.equalTo(60) }
        
        incognitoImageView.snp.makeConstraints { $0.width.height.equalTo(20) }
        historyImageView.snp.makeConstraints { $0.width.height.equalTo(20) }
        protectionImageView.snp.makeConstraints { $0.width.height.equalTo(20) }
        
        startBrowsingButton.snp.makeConstraints { make in
            make.width.equalTo(232)
            make.height.equalTo(36)
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

