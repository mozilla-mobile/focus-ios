/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        // NSItemProvider apparently doesn't support multiple attachments as a way to load multiple blocking lists.
        // As a workaround, we load each list into memory, then merge them into a single attachment.
        var mergedList = itemsFromFile("enabled-detector")

        if Settings.getToggle(.safari) {
            for list in Utils.getEnabledLists() {
                mergedList.append(contentsOf: itemsFromFile(list))
            }
        }

        let mergedListJSON = try! JSONSerialization.data(withJSONObject: mergedList, options: JSONSerialization.WritingOptions(rawValue: 0))
        let attachment = NSItemProvider(item: mergedListJSON as NSSecureCoding?, typeIdentifier: kUTTypeJSON as String)
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }

    /// Gets the dictionary form of the tracking list with the specified file name.
    private func itemsFromFile(_ name: String) -> [NSDictionary] {
        let url = Bundle.main.url(forResource: name, withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
    }
}
