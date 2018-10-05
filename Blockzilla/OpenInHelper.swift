/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import MobileCoreServices
import PassKit
import WebKit

struct MIMEType {
    static let Bitmap = "image/bmp"
    static let CSS = "text/css"
    static let GIF = "image/gif"
    static let JavaScript = "text/javascript"
    static let JPEG = "image/jpeg"
    static let HTML = "text/html"
    static let OctetStream = "application/octet-stream"
    static let Passbook = "application/vnd.apple.pkpass"
    static let PDF = "application/pdf"
    static let PlainText = "text/plain"
    static let PNG = "image/png"
    static let WebP = "image/webp"
    static let Calendar = "text/calendar"

    private static let webViewViewableTypes: [String] = [MIMEType.Bitmap, MIMEType.GIF, MIMEType.JPEG, MIMEType.HTML, MIMEType.PDF, MIMEType.PlainText, MIMEType.PNG, MIMEType.WebP]

    static func canShowInWebView(_ mimeType: String) -> Bool {
        return webViewViewableTypes.contains(mimeType.lowercased())
    }

    static func mimeTypeFromFileExtension(_ fileExtension: String) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeRetainedValue(), let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }

        return MIMEType.OctetStream
    }
}

protocol OpenInHelper {
    init?(request: URLRequest?, response: URLResponse, canShowInWebView: Bool, forceDownload: Bool, browserViewController: WebViewController)
    func open()
}

class OpenPassBookHelper: NSObject, OpenInHelper {
    fileprivate var url: URL

    fileprivate let browserViewController: WebViewController

    required init?(request: URLRequest?, response: URLResponse, canShowInWebView: Bool, forceDownload: Bool, browserViewController: WebViewController) {
        guard let mimeType = response.mimeType, mimeType == MIMEType.Passbook, PKAddPassesViewController.canAddPasses(),
            let responseURL = response.url, !forceDownload else { return nil }
        self.url = responseURL
        self.browserViewController = browserViewController
        super.init()
    }

    func open() {
        guard let passData = try? Data(contentsOf: url) else { return }

        do {
            let pass = try PKPass(data: passData)
            let passLibrary = PKPassLibrary()
            if passLibrary.containsPass(pass) {
                UIApplication.shared.open(pass.passURL!, options: [:])
            } else {
                let addController = PKAddPassesViewController(pass: pass)
                browserViewController.present(addController!, animated: true, completion: nil)
            }
        } catch {
            // display an error
            let alertController = UIAlertController(
                title: Strings.UnableToAddPassErrorTitle,
                message: Strings.UnableToAddPassErrorMessage,
                preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(title: Strings.UnableToAddPassErrorDismiss, style: .cancel) { (action) in
                    // Do nothing.
            })
            browserViewController.present(alertController, animated: true, completion: nil)
            return
        }
    }
}

class Strings { }

// errors
extension Strings {
    public static let UnableToAddPassErrorTitle = NSLocalizedString("AddPass.Error.Title", value: "Failed to Add Pass", comment: "Title of the 'Add Pass Failed' alert. See https://support.apple.com/HT204003 for context on Wallet.")
    public static let UnableToAddPassErrorMessage = NSLocalizedString("AddPass.Error.Message", value: "An error occured while adding the pass to Wallet. Please try again later.", comment: "Text of the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
    public static let UnableToAddPassErrorDismiss = NSLocalizedString("AddPass.Error.Dismiss", value: "OK", comment: "Button to dismiss the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
}
