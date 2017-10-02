//
//  BrowserViewController.swift
//  Blockzilla
//
//  Created by Jeff Boek on 9/19/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit
import WebKit

protocol WebController {
    var delegate: WebControllerDelegate? { get set }
    func load(_ request: URLRequest)
}

protocol WebControllerDelegate: class {
    func webController(_ controller: WebController, scrollViewWillBeginDragging scrollView: UIScrollView)
    func webController(_ controller: WebController, scrollViewDidEndDragging scrollView: UIScrollView)
    func webController(_ controller: WebController, scrollViewDidScroll scrollView: UIScrollView)
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
