/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Telemetry

private let internalSchemes: Set<String> = ["http", "https", "ftp", "file", "about", "javascript", "data"]

class RequestHandler {
    private var alertCallback: (UIAlertController) -> Void = { _ in }
    private var title: String = ""
    private var url: URL!

    func handle(request: URLRequest, alertCallback: @escaping (UIAlertController) -> Void) -> Bool {
        self.alertCallback = alertCallback

        if !isValidURLAndScheme(url: request.url, scheme: request.url?.scheme) { return false }

        url = request.url!
        let scheme = request.url!.scheme!

        guard internalSchemes.contains(scheme) else {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !isValidURLComponents(components) { return false }
            title = components!.path
            return handleURLScheme(scheme)
        }

        guard scheme == "http" || scheme == "https",
              let host = url.host?.lowercased() else {
            return true
        }
        return handleURLHost(host)
    }

    private func isValidURLAndScheme(url: URL?, scheme: String?) -> Bool {
        guard url != nil, scheme != nil else { return false }
        return true
    }

    private func isValidURLComponents(_ components: URLComponents?) -> Bool {
        guard components != nil else { return false }
        return true
    }

    private func handleURLScheme(_ scheme: String) -> Bool {
        switch scheme {
        case "tel":
            // Don't present our dialog as the system presents its own
            UIApplication.shared.open(url, options: [:])
        case "facetime", "facetime-audio":
            presentAlert(title: title, action: "FaceTime", for: url)
        case "mailto":
            presentAlert(title: title, action: UIConstants.strings.externalLinkEmail, for: url)
        default:
            presentAlert(title: String(format: UIConstants.strings.externalAppLink, AppInfo.productName),
                         action: UIConstants.strings.open,
                         for: url,
                         telemetryEvent: true)
        }
        return false
    }

    private func handleURLHost(_ host: String) -> Bool {
        switch host {
        case "maps.apple.com":
            presentAlert(title: String(format: UIConstants.strings.externalAppLinkWithAppName, AppInfo.productName, "Maps"),
                         action: UIConstants.strings.open,
                         for: url)
            return false
        case "itunes.apple.com":
            presentAlert(title: String(format: UIConstants.strings.externalAppLinkWithAppName, AppInfo.productName, "App Store"),
                         action: UIConstants.strings.open,
                         for: url)
            return false
        default:
            return true
        }
    }

    private func presentAlert(title: String, action: String, for url: URL, telemetryEvent: Bool = false) {
        let alert = makeAlert(title: title, action: action, forURL: url, telemetryEvent: telemetryEvent)
        alertCallback(alert)
    }

    private func makeAlert(title: String, action: String, forURL url: URL, telemetryEvent: Bool = false) -> UIAlertController {
        let openAction = UIAlertAction(title: action, style: .default) { _ in
            if telemetryEvent {
                Telemetry.default.recordEvent(category: TelemetryEventCategory.action,
                                              method: TelemetryEventMethod.open,
                                              object: TelemetryEventObject.requestHandler,
                                              value: "external link")
            }
            UIApplication.shared.open(url, options: [:])
        }
        let cancelAction = UIAlertAction(title: UIConstants.strings.externalLinkCancel, style: .cancel) { _ in
            if telemetryEvent {
                Telemetry.default.recordEvent(category: TelemetryEventCategory.action,
                                              method: TelemetryEventMethod.cancel,
                                              object: TelemetryEventObject.requestHandler,
                                              value: "external link")
            }
        }
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        alert.preferredAction = openAction
        return alert
    }
}
