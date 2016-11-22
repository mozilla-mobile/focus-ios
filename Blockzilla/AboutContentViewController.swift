/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import UIKit
import WebKit

class AboutContentViewController: UIViewController, WKNavigationDelegate {
    private let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIConstants.colors.background

        let webView = WKWebView()
        webView.alpha = 0
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)

        webView.snp.remakeConstraints { make in
            make.edges.equalTo(view)
        }

        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        revealWebView(webView)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        revealWebView(webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        revealWebView(webView)
    }

    private func revealWebView(_ webView: WKWebView) {
        // Add a small delay to allow the stylesheets to load and avoid flicker.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            webView.animateHidden(false, duration: 0.3)
        }
    }
}
