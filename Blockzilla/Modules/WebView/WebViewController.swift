/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import WebKit

protocol BrowserState {
    var url: URL? { get }
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
    func webController(_ controller: WebController, scrollViewWillBeginDragging scrollView: UIScrollView)
    func webController(_ controller: WebController, scrollViewDidEndDragging scrollView: UIScrollView)
    func webController(_ controller: WebController, scrollViewDidScroll scrollView: UIScrollView)
    func webController(_ controller: WebController, stateDidChange state: BrowserState)
    func webControllerShouldScrollToTop(_ controller: WebController) -> Bool
}

class WebViewController: UIViewController, WebController {
    weak var delegate: WebControllerDelegate?

    private let browserView = WKWebView()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        browserView.allowsBackForwardNavigationGestures = true
        browserView.allowsLinkPreview = false
        browserView.scrollView.delegate = self
    }

    override func loadView() {
        self.view = browserView
    }

    func load(_ request: URLRequest) {
        browserView.load(request)
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

}

extension WebViewController: BrowserState {
    var canGoBack: Bool { return browserView.canGoBack }
    var canGoForward: Bool { return browserView.canGoForward }
    var url: URL? { return browserView.url }
    var estimatedProgress: Double { return browserView.estimatedProgress }
}

