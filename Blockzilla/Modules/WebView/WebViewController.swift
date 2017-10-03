/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import WebKit

protocol BrowserState {
    var url: URL? { get }
    var isLoading: Bool { get }
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }
    var estimatedProgress: Double { get }
}

protocol WebController {
    weak var delegate: WebControllerDelegate? { get set }
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func load(_ request: URLRequest)
}

protocol WebControllerDelegate: class {
    func webControllerDidStartNavigation(_ controller: WebController)
    func webControllerDidFinishNavigation(_ controller: WebController)
    func webController(_ controller: WebController, didUpdateEstimatedProgress estimatedProgress: Double)
    func webController(_ controller: WebController, scrollViewWillBeginDragging scrollView: UIScrollView)
    func webController(_ controller: WebController, scrollViewDidEndDragging scrollView: UIScrollView)
    func webController(_ controller: WebController, scrollViewDidScroll scrollView: UIScrollView)
    func webController(_ controller: WebController, stateDidChange state: BrowserState)
    func webControllerShouldScrollToTop(_ controller: WebController) -> Bool


//    func browserDidStartNavigation(_ browser: Browser)
//    func browserDidFinishNavigation(_ browser: Browser)
//    func browser(_ browser: Browser, didFailNavigationWithError error: Error)
//    func browser(_ browser: Browser, didUpdateCanGoBack canGoBack: Bool)
//    func browser(_ browser: Browser, didUpdateCanGoForward canGoForward: Bool)
//    func browser(_ browser: Browser, didUpdateEstimatedProgress estimatedProgress: Float)
//    func browser(_ browser: Browser, didUpdateURL url: URL?)
//    func browser(_ browser: Browser, didLongPressImage path: String?, link: String?)
//    func browser(_ browser: Browser, shouldStartLoadWith request: URLRequest) -> Bool
//    func browser(_ browser: Browser, scrollViewWillBeginDragging scrollView: UIScrollView)
//    func browser(_ browser: Browser, scrollViewDidEndDragging scrollView: UIScrollView)
//    func browser(_ browser: Browser, scrollViewDidScroll scrollView: UIScrollView)
//    func browserShouldScrollToTop(_ browser: Browser) -> Bool
}



class WebViewController: UIViewController, WebController {
    weak var delegate: WebControllerDelegate?

    private var browserView = WKWebView()
    private var progressObserver: NSKeyValueObservation?

    var printFormatter: UIPrintFormatter { return browserView.viewPrintFormatter() }
    var scrollView: UIScrollView { return browserView.scrollView }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        setupWebview()
    }


    override func loadView() {
        self.view = browserView
    }
//
//    override func viewPrintFormatter() {
//        return browserView.viewPrintFormatter()
//    }

    func reset() {
        browserView.load(URLRequest(url: URL(string: "about:blank")!))
        browserView.navigationDelegate = nil
        setupWebview()
        self.view = browserView
    }

    // Browser proxy methods
    func load(_ request: URLRequest) { browserView.load(request) }
    func goBack() { browserView.goBack() }
    func goForward() { browserView.goForward() }
    func reload() { browserView.reload() }
    func stop() { browserView.stopLoading() }


    private func setupWebview() {
        browserView.allowsBackForwardNavigationGestures = true
        browserView.allowsLinkPreview = false
        browserView.scrollView.delegate = self
        browserView.navigationDelegate = self
        progressObserver = browserView.observe(\WKWebView.estimatedProgress) { (webView, value) in
            self.delegate?.webController(self, didUpdateEstimatedProgress: webView.estimatedProgress)
        }

        ContentBlockerHelper.getBlockLists { lists in
            DispatchQueue.main.async {
                lists.forEach(self.browserView.configuration.userContentController.add)
            }
        }
    }
}

extension WebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.webController(self, scrollViewDidScroll: scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.webController(self, scrollViewWillBeginDragging: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.webController(self, scrollViewDidEndDragging: scrollView)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return delegate?.webControllerShouldScrollToTop(self) ?? true
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        delegate?.webControllerDidStartNavigation(self)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webControllerDidFinishNavigation(self)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let present: (UIViewController) -> Void = { self.present($0, animated: true, completion: nil) }
        let decision: WKNavigationActionPolicy = RequestHandler().handle(request: navigationAction.request, alertCallback: present) ? .allow : .cancel
        decisionHandler(decision)
    }
}

extension WebViewController: BrowserState {
    var canGoBack: Bool { return browserView.canGoBack }
    var canGoForward: Bool { return browserView.canGoForward }
    var estimatedProgress: Double { return browserView.estimatedProgress }
    var isLoading: Bool { return browserView.isLoading }
    var url: URL? { return browserView.url }
}

