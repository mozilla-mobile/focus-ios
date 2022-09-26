/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Telemetry
import Glean
import Sentry
import Combine
import Onboarding
import AppShortcuts

enum AppPhase {
    case notRunning
    case didFinishLaunching
    case willEnterForeground
    case didBecomeActive
    case willResignActive
    case didEnterBackgroundkground
    case willTerminate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private lazy var authenticationManager = AuthenticationManager()
    @Published private var appPhase: AppPhase = .notRunning

    // This enum can be expanded to support all new shortcuts added to menu.
    enum ShortcutIdentifier: String {
        case EraseAndOpen
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }

    var window: UIWindow?

    lazy var splashView: SplashView = {
        let splashView = SplashView()
        splashView.authenticationManager = authenticationManager
        return splashView
    }()

    private lazy var browserViewController = BrowserViewController(
        shortcutManager: shortcutManager,
        authenticationManager: authenticationManager,
        onboardingEventsHandler: onboardingEventsHandler,
        themeManager: themeManager
    )

    private let nimbus = NimbusWrapper.shared
    private var queuedUrl: URL?
    private var queuedString: String?
    private let themeManager = ThemeManager()
    private var cancellables = Set<AnyCancellable>()
    private lazy var shortcutManager: ShortcutsManager = .init()

    private lazy var onboardingEventsHandler: OnboardingEventsHandling = {
        var shouldShowNewOnboarding: () -> Bool = { [unowned self] in
            #if DEBUG
            if UserDefaults.standard.bool(forKey: OnboardingConstants.ignoreOnboardingExperiment) {
                return !UserDefaults.standard.bool(forKey: OnboardingConstants.showOldOnboarding)
            } else {
                return nimbus.shouldShowNewOnboarding
            }
            #else
            return nimbus.shouldShowNewOnboarding
            #endif
    }
        guard !AppInfo.isTesting() else { return TestOnboarding() }
        return OnboardingFactory.makeOnboardingEventsHandler(shouldShowNewOnboarding)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appPhase = .didFinishLaunching

        $appPhase.sink { [unowned self] phase in
            switch phase {
            case .didFinishLaunching, .willEnterForeground:
                authenticateWithBiometrics()

            case .didBecomeActive:
                if authenticationManager.authenticationState == .loggedin { hideSplashView() }

            case .willResignActive:
                showSplashView()

            case .didEnterBackgroundkground:
                authenticationManager.logout()

            case .notRunning, .willTerminate:
                break
            }
        }
        .store(in: &cancellables)

        authenticationManager
            .$authenticationState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .loggedin:
                    self.hideSplashView()

                case .loggedout:
                    self.splashView.state = .default
                    self.showSplashView()

                case .canceled:
                    self.splashView.state = .needsAuth
                }
            }
            .store(in: &cancellables)

        if AppInfo.testRequestsReset() {
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
            UserDefaults.standard.removePersistentDomain(forName: AppInfo.sharedContainerIdentifier)
        }

        setupCrashReporting()
        setupTelemetry()
        setupExperimentation()

        TPStatsBlocklistChecker.shared.startup()

        // Fix transparent navigation bar issue in iOS 15
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryText]
            appearance.backgroundColor = .systemGroupedBackground
            appearance.shadowColor = .clear
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

        // Count number of app launches for requesting a review
        let currentLaunchCount = UserDefaults.standard.integer(forKey: UIConstants.strings.userDefaultsLaunchCountKey)
        UserDefaults.standard.set(currentLaunchCount + 1, forKey: UIConstants.strings.userDefaultsLaunchCountKey)

        // Disable localStorage.
        // We clear the Caches directory after each Erase, but WebKit apparently maintains
        // localStorage in-memory (bug 1319208), so we just disable it altogether.
        UserDefaults.standard.set(false, forKey: "WebKitLocalStorageEnabledPreferenceKey")
        UserDefaults.standard.removeObject(forKey: "searchedHistory")

        // Re-register the blocking lists at startup in case they've changed.
        Utils.reloadSafariContentBlocker()

        window = UIWindow(frame: UIScreen.main.bounds)

        browserViewController.modalDelegate = self
        window?.rootViewController = browserViewController
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = themeManager.selectedTheme

        WebCacheUtils.reset()

        KeyboardHelper.defaultHelper.startObserving()

        if AppInfo.isTesting() {
            // Only show the First Run UI if the test asks for it.
            if AppInfo.isFirstRunUIEnabled() {
                onboardingEventsHandler.send(.applicationDidLaunch)
            }
            return true
        }

        onboardingEventsHandler.send(.applicationDidLaunch)
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let navigation = NavigationPath(url: url) else { return false }
        let navigationHandler = NavigationPath.handle(application, navigation: navigation, with: browserViewController)

        if case .text = navigation {
            queuedString = navigationHandler as? String
        }
        else if case .url = navigation {
            queuedUrl = navigationHandler as? URL
        }

        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {

        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }

    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        switch shortcutIdentifier {
        case .EraseAndOpen:
            browserViewController.photonActionSheetDidDismiss()
            browserViewController.dismiss(animated: true, completion: nil)
            browserViewController.navigationController?.popViewController(animated: true)
            browserViewController.resetBrowser(hidePreviousSession: true)
        }
        return true
    }

    private func authenticateWithBiometrics() {
        Task {
            await authenticationManager.authenticateWithBiometrics()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        appPhase = .willResignActive
        browserViewController.dismissActionSheet()
        browserViewController.deactivateUrlBar()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appPhase = .didBecomeActive

        if Settings.siriRequestsErase() {
            browserViewController.photonActionSheetDidDismiss()
            browserViewController.dismiss(animated: true, completion: nil)
            browserViewController.navigationController?.popViewController(animated: true)
            browserViewController.resetBrowser(hidePreviousSession: true)
            Settings.setSiriRequestErase(to: false)
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.siri, object: TelemetryEventObject.eraseInBackground)
            GleanMetrics.Siri.eraseInBackground.record()
        }
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.foreground, object: TelemetryEventObject.app)

        if let url = queuedUrl {
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.openedFromExtension, object: TelemetryEventObject.app)

            browserViewController.ensureBrowsingMode()
            browserViewController.deactivateUrlBarOnHomeView()
            browserViewController.dismissSettings()
            browserViewController.dismissActionSheet()
            browserViewController.submit(url: url)
            queuedUrl = nil
        } else if let text = queuedString {
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.openedFromExtension, object: TelemetryEventObject.app)

            browserViewController.ensureBrowsingMode()
            browserViewController.deactivateUrlBarOnHomeView()
            browserViewController.dismissSettings()
            browserViewController.dismissActionSheet()

            if let fixedUrl = URIFixup.getURL(entry: text) {
                browserViewController.submit(url: fixedUrl)
            } else {
                browserViewController.submit(text: text)
            }

            queuedString = nil
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        appPhase = .willEnterForeground
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Record an event indicating that we have entered the background and end our telemetry
        // session. This gets called every time the app goes to background but should not get
        // called for *temporary* interruptions such as an incoming phone call until the user
        // takes action and we are officially backgrounded.
        appPhase = .didEnterBackgroundkground
        let orientation = UIDevice.current.orientation.isPortrait ? "Portrait" : "Landscape"
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.background, object:
            TelemetryEventObject.app, value: nil, extras: ["orientation": orientation])
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        browserViewController.photonActionSheetDidDismiss()
        browserViewController.dismiss(animated: true, completion: nil)
        browserViewController.navigationController?.popViewController(animated: true)

        switch userActivity.activityType {
        case "org.mozilla.ios.Klar.eraseAndOpen":
            browserViewController.resetBrowser(hidePreviousSession: true)
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.siri, object: TelemetryEventObject.eraseAndOpen)
            GleanMetrics.Siri.eraseAndOpen.record()
        case "org.mozilla.ios.Klar.openUrl":
            guard let urlString = userActivity.userInfo?["url"] as? String,
                let url = URL(string: urlString) else { return false }
            browserViewController.resetBrowser(hidePreviousSession: true)
            browserViewController.ensureBrowsingMode()
            browserViewController.deactivateUrlBarOnHomeView()
            browserViewController.submit(url: url)
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.siri, object: TelemetryEventObject.openFavoriteSite)
            GleanMetrics.Siri.openFavoriteSite.record()
        case "EraseIntent":
            guard userActivity.interaction?.intent as? EraseIntent != nil else { return false }
            browserViewController.resetBrowser()
            Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.siri, object: TelemetryEventObject.eraseInBackground)
            GleanMetrics.Siri.eraseInBackground.record()
        default: break
        }
        return true
    }

    func hideSplashView() {
        browserViewController.activateUrlBarOnHomeView()
        splashView.alpha = 0
        splashView.isHidden = true
        splashView.removeFromSuperview()
    }

    func showSplashView() {
        browserViewController.deactivateUrlBarOnHomeView()
        window!.addSubview(splashView)
        splashView.snp.makeConstraints { make in
            make.edges.equalTo(window!)
        }
        splashView.alpha = 1
        splashView.isHidden = false
    }
}

// MARK: - Crash Reporting

private let SentryDSNKey = "SentryDSN"

extension AppDelegate {
    func setupCrashReporting() {
        // Do not enable crash reporting if collection of anonymous usage data is disabled.
        if !Settings.getToggle(.sendAnonymousUsageData) {
            return
        }

        if let sentryDSN = Bundle.main.object(forInfoDictionaryKey: SentryDSNKey) as? String {
            SentrySDK.start { options in
                options.dsn = sentryDSN
            }
        }
    }
}

// MARK: - Telemetry & Tooling setup
extension AppDelegate {

    func setupTelemetry() {

        let telemetryConfig = Telemetry.default.configuration
        telemetryConfig.appName = AppInfo.isKlar ? "Klar" : "Focus"
        telemetryConfig.userDefaultsSuiteName = AppInfo.sharedContainerIdentifier
        telemetryConfig.appVersion = AppInfo.shortVersion

        // Since Focus always clears the caches directory and Telemetry files are
        // excluded from iCloud backup, we store pings in documents.
        telemetryConfig.dataDirectory = .documentDirectory

        let activeSearchEngine = SearchEngineManager(prefs: UserDefaults.standard).activeEngine
        let defaultSearchEngineProvider = activeSearchEngine.isCustom ? "custom" : activeSearchEngine.name
        telemetryConfig.defaultSearchEngineProvider = defaultSearchEngineProvider

        telemetryConfig.measureUserDefaultsSetting(forKey: SearchEngineManager.prefKeyEngine, withDefaultValue: defaultSearchEngineProvider)
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockAds, withDefaultValue: Settings.getToggle(.blockAds))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockAnalytics, withDefaultValue: Settings.getToggle(.blockAnalytics))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockSocial, withDefaultValue: Settings.getToggle(.blockSocial))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockOther, withDefaultValue: Settings.getToggle(.blockOther))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockFonts, withDefaultValue: Settings.getToggle(.blockFonts))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.biometricLogin, withDefaultValue: Settings.getToggle(.biometricLogin))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.enableSearchSuggestions, withDefaultValue: Settings.getToggle(.enableSearchSuggestions))

        #if DEBUG
            telemetryConfig.updateChannel = "debug"
            telemetryConfig.isCollectionEnabled = false
            telemetryConfig.isUploadEnabled = false
        #else
            telemetryConfig.updateChannel = "release"
            telemetryConfig.isCollectionEnabled = Settings.getToggle(.sendAnonymousUsageData)
            telemetryConfig.isUploadEnabled = Settings.getToggle(.sendAnonymousUsageData)
        #endif

        Telemetry.default.add(pingBuilderType: CorePingBuilder.self)
        Telemetry.default.add(pingBuilderType: FocusEventPingBuilder.self)

        // Start the telemetry session and record an event indicating that we have entered the
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.foreground, object: TelemetryEventObject.app)

        if let clientId = UserDefaults
            .standard.string(forKey: "telemetry-key-prefix-clientId")
            .flatMap(UUID.init(uuidString:)) {
            GleanMetrics.LegacyIds.clientId.set(clientId)
        }

        if UserDefaults.standard.bool(forKey: GleanLogPingsToConsole) {
            Glean.shared.handleCustomUrl(url: URL(string: "focus-glean-settings://glean?logPings=true")!)
        }

        if UserDefaults.standard.bool(forKey: GleanEnableDebugView) {
            if let tag = UserDefaults.standard.string(forKey: GleanDebugViewTag), !tag.isEmpty, let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlQueryParameterAllowed) {
                Glean.shared.handleCustomUrl(url: URL(string: "focus-glean-settings://glean?debugViewTag=\(encodedTag)")!)
            }
        }

        let channel = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "testflight" : "release"
        Glean.shared.initialize(uploadEnabled: Settings.getToggle(.sendAnonymousUsageData), configuration: Configuration(channel: channel), buildInfo: GleanMetrics.GleanBuild.info)

        // Send "at startup" telemetry
        GleanMetrics.Shortcuts.shortcutsOnHomeNumber.set(Int64(shortcutManager.shortcutsViewModels.count))
        GleanMetrics.TrackingProtection.hasAdvertisingBlocked.set(Settings.getToggle(.blockAds))
        GleanMetrics.TrackingProtection.hasAnalyticsBlocked.set(Settings.getToggle(.blockAnalytics))
        GleanMetrics.TrackingProtection.hasContentBlocked.set(Settings.getToggle(.blockOther))
        GleanMetrics.TrackingProtection.hasSocialBlocked.set(Settings.getToggle(.blockSocial))
        GleanMetrics.MozillaProducts.hasFirefoxInstalled.set(UIApplication.shared.canOpenURL(URL(string: "firefox://")!))
        GleanMetrics.Preferences.userTheme.set(UserDefaults.standard.theme.telemetryValue)
    }

    func setupExperimentation() {
        do {
            // Enable nimbus when both Send Usage Data and Studies are enabled in the settings.
            try NimbusWrapper.shared.initialize(enabled: Settings.getToggle(.sendAnonymousUsageData) && Settings.getToggle(.studies))
        } catch {
            NSLog("Failed to setup experimentation: \(error)")
        }
    }
}

extension AppDelegate: ModalDelegate {
    func dismiss(animated: Bool = true) {
        window?.rootViewController?.presentedViewController?.dismiss(animated: animated)
    }

    func presentModal(viewController: UIViewController, animated: Bool) {
        window?.rootViewController?.present(viewController, animated: animated, completion: nil)
    }

    func presentSheet(viewController: UIViewController) {
        let vc = SheetModalViewController(containerViewController: viewController)
        vc.modalPresentationStyle = .overCurrentContext
        // keep false
        // modal animation will be handled in VC itself
        window?.rootViewController?.present(vc, animated: false)
    }
}

protocol ModalDelegate {
    func presentModal(viewController: UIViewController, animated: Bool)
    func presentSheet(viewController: UIViewController)
    func dismiss(animated: Bool)
}
