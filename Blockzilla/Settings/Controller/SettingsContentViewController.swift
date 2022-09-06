/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import WebKit

let DefaultTimeoutTimeInterval = 10.0 // Seconds.  We'll want some telemetry on load times in the wild.

/**
 * A controller that manages a single web view and provides a way for
 * the user to navigate back to Settings.
 */
class SettingsContentViewController: UIViewController, WKNavigationDelegate {
    let interstitialBackgroundColor: UIColor
    var url: URL
    var timer: Timer?

    var isLoaded: Bool = false {
        didSet {
            if isLoaded {
                // Add a small delay to allow the stylesheets to load and avoid flicker.
                let delayTime = DispatchTime.now() + Double(Int64(200 * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    UIView.transition(from: self.interstitialView, to: self.webView,
                                      duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      completion: { finished in
                                        self.interstitialView.removeFromSuperview()
                                        self.interstitialSpinnerView.stopAnimating()
                    })
                }
            }
        }
    }

    private var isError: Bool = false {
        didSet {
            if isError {
                interstitialErrorView.isHidden = false
                // Add a small delay to allow the stylesheets to load and avoid flicker.
                let delayTime = DispatchTime.now() + Double(Int64(200 * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    UIView.transition(from: self.interstitialSpinnerView, to: self.interstitialErrorView,
                                      duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      completion: { finished in
                                        self.interstitialSpinnerView.removeFromSuperview()
                                        self.interstitialSpinnerView.stopAnimating()
                    })
                }
            }
        }
    }

    // The view shown while the content is loading in the background web view.
    private var interstitialView: UIView!
    private var interstitialSpinnerView: UIActivityIndicatorView!
    private var interstitialErrorView: UILabel!

    // The web view that displays content.
    var webView: WKWebView!

    private func startLoading(_ timeout: Double = DefaultTimeoutTimeInterval) {
        if self.isLoaded {
            return
        }
        if timeout > 0 {
            self.timer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(SettingsContentViewController.SELdidTimeOut), userInfo: nil, repeats: false)
        } else {
            self.timer = nil
        }
        self.webView.load(URLRequest(url: url))
        self.interstitialSpinnerView.startAnimating()
    }

    init(url: URL, backgroundColor: UIColor = .systemBackground) {
        interstitialBackgroundColor = backgroundColor
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // This background agrees with the web page background.
        // Keeping the background constant prevents a pop of mismatched color.
        view.backgroundColor = interstitialBackgroundColor
        navigationController?.navigationBar.tintColor = .accent

        self.webView = makeWebView()
        view.addSubview(webView)

        // Destructuring let causes problems.
        let ret = makeInterstitialViews()
        self.interstitialView = ret.0
        self.interstitialSpinnerView = ret.1
        self.interstitialErrorView = ret.2
        view.addSubview(interstitialView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        interstitialView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            interstitialView.topAnchor.constraint(equalTo: view.topAnchor),
            interstitialView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            interstitialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            interstitialView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        startLoading()
    }

    func makeWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 1, height: 1),
            configuration: config
        )
        webView.allowsLinkPreview = false
        webView.navigationDelegate = self
        return webView
    }

    private func makeInterstitialViews() -> (UIView, UIActivityIndicatorView, UILabel) {
        let view = UIView()

        // Keeping the background constant prevents a pop of mismatched color.
        view.backgroundColor = interstitialBackgroundColor

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        let error = SmartLabel()
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.topAnchor),
            spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spinner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        return (view, spinner, error)
    }

    @objc func SELdidTimeOut() {
        self.timer = nil
        self.isError = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        SELdidTimeOut()
        let errorPageData = ErrorPage(error: error).data
        webView.load(errorPageData, mimeType: "", characterEncodingName: "", baseURL: url)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SELdidTimeOut()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.timer?.invalidate()
        self.timer = nil
        self.isLoaded = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let isLicensePage = navigationAction.request.url?.pathComponents.last.map({ $0 == "licenses.html" }) ?? false

        guard !isLicensePage else {
            decisionHandler(.cancel)
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            return
        }

        decisionHandler(.allow)
    }
}
