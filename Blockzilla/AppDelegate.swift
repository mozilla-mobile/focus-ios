/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Telemetry

private let WEBKIT_LOCAL_STORAGE_ENABLED_KEY = "WebKitLocalStorageEnabledPreferenceKey"
private let WAS_TELEMETRY_SETTING_PERSISTED = "Wasv3.2TelemetrySettingPersisted"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var splashView: UIView?
    private static let prefIntroDone = "IntroDone"
    private static let prefIntroVersion = 2

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if BUDDYBUILD
            BuddyBuildSDK.setup()
        #endif
        
        // Set up Telemetry
        let telemetryConfig = Telemetry.default.configuration
        telemetryConfig.appName = AppInfo.isKlar ? "Klar" : "Focus"
        telemetryConfig.userDefaultsSuiteName = AppInfo.sharedContainerIdentifier

        // Since Focus always clears the caches directory and Telemetry files are
        // excluded from iCloud backup, we store pings in documents.
        telemetryConfig.dataDirectory = .documentDirectory
        
        let defaultSearchEngineProvider = SearchEngineManager(prefs: UserDefaults.standard).engines.first?.name ?? "unknown"
        telemetryConfig.defaultSearchEngineProvider = defaultSearchEngineProvider
        
        telemetryConfig.measureUserDefaultsSetting(forKey: SearchEngineManager.prefKeyEngine, withDefaultValue: defaultSearchEngineProvider)
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockAds, withDefaultValue: Settings.getToggle(.blockAds))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockAnalytics, withDefaultValue: Settings.getToggle(.blockAnalytics))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockSocial, withDefaultValue: Settings.getToggle(.blockSocial))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockOther, withDefaultValue: Settings.getToggle(.blockOther))
        telemetryConfig.measureUserDefaultsSetting(forKey: SettingsToggle.blockFonts, withDefaultValue: Settings.getToggle(.blockFonts))
        
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
        
        // Only include Adjust SDK in Focus and NOT in Klar builds.
        #if FOCUS
            // Always initialize Adjust, otherwise the SDK is in a bad state. We disable it
            // immediately so that no data is collected or sent.
            AdjustIntegration.applicationDidFinishLaunching()
            if !Settings.getToggle(.sendAnonymousUsageData) {
                AdjustIntegration.enabled = false
            }
        #endif

        // Disable localStorage.
        // We clear the Caches directory after each Erase, but WebKit apparently maintains
        // localStorage in-memory (bug 1319208), so we just disable it altogether.
        //
        // HACK isFirstRun: since we disable local storage every time the app starts, if it hasn't
        // been set yet, it must be first run.
        let userDefaults = UserDefaults.standard
        let isFirstRun = userDefaults.object(forKey: WEBKIT_LOCAL_STORAGE_ENABLED_KEY) as? Bool == nil // .bool returns false if key DNE so can't be used for existence queries.
        userDefaults.set(false, forKey: WEBKIT_LOCAL_STORAGE_ENABLED_KEY)

        maybePersistV3_2TelemetrySetting(isFirstRun: isFirstRun)

        // Set up our custom user agent.
        UserAgent.setup()

        // Re-register the blocking lists at startup in case they've changed.
        Utils.reloadSafariContentBlocker()

        LocalWebServer.sharedInstance.start()

        window = UIWindow(frame: UIScreen.main.bounds)
        let browserViewController = BrowserViewController()
        let rootViewController = UINavigationController(rootViewController: browserViewController)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        WebCacheUtils.reset()

        URLProtocol.registerClass(LocalContentBlocker.self)

        displaySplashAnimation()
        KeyboardHelper.defaultHelper.startObserving()

        if UserDefaults.standard.integer(forKey: AppDelegate.prefIntroDone) < AppDelegate.prefIntroVersion {
            UserDefaults.standard.set(AppDelegate.prefIntroVersion, forKey: AppDelegate.prefIntroDone)

            // Show the first run UI asynchronously to avoid the "unbalanced calls to begin/end appearance transitions" warning.
            DispatchQueue.main.async {
                let firstRunViewController = FirstRunViewController()
                rootViewController.present(firstRunViewController, animated: false, completion: nil)
            }
        }

        return true
    }

    /// HACK: in v3.3, we removed Adjust from Klar and defaulted to opt-in telemetry for new Klar
    /// users. For existing Klar users, we wish to honor their current telemetry setting - this
    /// method is to persist their v3.2 telemetry value.
    ///
    /// There are three kinds of Klar users & three actions to take:
    /// - New users: do nothing here & use the new default value in Settings.
    /// - Existing users who have toggled the pref: do nothing here - their value is already persisted
    /// - Existing users who have *not* toggled the pref: persist true here - the old default value
    /// was opt-out
    fileprivate func maybePersistV3_2TelemetrySetting(isFirstRun: Bool) {
        let userDefaults = UserDefaults.standard

        // If this is called a second time, new users will be considered existing
        // users so we only run this once.
        guard !userDefaults.bool(forKey: WAS_TELEMETRY_SETTING_PERSISTED) else { return }
        defer { userDefaults.set(true, forKey: WAS_TELEMETRY_SETTING_PERSISTED) }

        // Persist true for existing users who have not toggled the pref (see above).
        if AppInfo.isKlar,
            !isFirstRun, // i.e. an existing user
            !Settings.isToggleValuePersisted(.sendAnonymousUsageData) { // never overriden by user.
            Settings.set(true, forToggle: .sendAnonymousUsageData) // TODO: persists immediately?
        }
    }

    fileprivate func displaySplashAnimation() {
        let splashView = UIView()
        splashView.backgroundColor = UIConstants.colors.background
        window!.addSubview(splashView)

        let logoImage = UIImageView(image: AppInfo.config.wordmark)
        splashView.addSubview(logoImage)

        splashView.snp.makeConstraints { make in
            make.edges.equalTo(window!)
        }

        logoImage.snp.makeConstraints { make in
            make.center.equalTo(splashView)
        }

        let animationDuration = 0.25
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            logoImage.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0)
        }, completion: { success in
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                splashView.alpha = 0
                logoImage.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
            }, completion: { success in
                splashView.isHidden = true
                logoImage.layer.transform = CATransform3DIdentity
                self.splashView = splashView
            })
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        splashView?.animateHidden(false, duration: 0)
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.background, object: TelemetryEventObject.app)
        Telemetry.default.recordSessionEnd()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        splashView?.animateHidden(true, duration: 0.25)
        Telemetry.default.recordSessionStart()
        Telemetry.default.recordEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.foreground, object: TelemetryEventObject.app)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Telemetry.default.queue(pingType: CorePingBuilder.PingType)
        Telemetry.default.queue(pingType: FocusEventPingBuilder.PingType)
        Telemetry.default.scheduleUpload(pingType: CorePingBuilder.PingType)
        Telemetry.default.scheduleUpload(pingType: FocusEventPingBuilder.PingType)
    }

    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        // We don't currently support third-party keyboards due to incompatibilities with our
        // autocomplete text field (e.g., bug 1317104).
        return extensionPointIdentifier != UIApplicationExtensionPointIdentifier.keyboard
    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
