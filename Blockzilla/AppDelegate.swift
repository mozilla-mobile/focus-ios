/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import AdjustSdk

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

        // Always initialize Adjust, otherwise the SDK is in a bad state. We disable it
        // immediately so that no data is collected or sent.
        AdjustIntegration.applicationDidFinishLaunching()
        if !Settings.getToggle(.sendAnonymousUsageData) {
            AdjustIntegration.enabled = false
        }

        // Disable localStorage.
        // We clear the Caches directory after each Erase, but WebKit apparently maintains
        // localStorage in-memory (bug 1319208), so we just disable it altogether.
        UserDefaults.standard.set(false, forKey: "WebKitLocalStorageEnabledPreferenceKey")

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

    fileprivate func displaySplashAnimation() {
        let splashView = UIView()
        splashView.backgroundColor = UIConstants.colors.background
        window!.addSubview(splashView)

        let wordmark = AppInfo.isFocus ? #imageLiteral(resourceName: "img_focus_wordmark") : #imageLiteral(resourceName: "img_klar_wordmark")
        let logoImage = UIImageView(image: wordmark)
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
        splashView?.animateHidden(false, duration: 0.25)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        splashView?.animateHidden(true, duration: 0.25)
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
