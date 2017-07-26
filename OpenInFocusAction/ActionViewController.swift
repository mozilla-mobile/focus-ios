/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        guard let braveUrl = NSURL(string: "https://www.google.com") else { return }
        let context = NSExtensionContext()
        context.open(braveUrl as URL, completionHandler: nil)
        print("HELLOOO1")

        // From http://stackoverflow.com/questions/24297273/openurl-not-work-in-action-extension
        var responder = self as UIResponder?
        while (responder != nil) {
            print("HELLOOO")
            let selectorOpenURL = sel_registerName("openURL:")
            if responder!.responds(to: selectorOpenURL) {
                responder!.perform(selectorOpenURL, with: braveUrl)
            }
            responder = responder!.next
        }
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
                        OperationQueue.main.addOperation {
                            if let strongImageView = weakImageView {
                                if let imageURL = imageURL as? URL {
                                    strongImageView.image = UIImage(data: try! Data(contentsOf: imageURL))
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
//        guard let url = (urlItem as! NSURL).absoluteString?.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.alphanumerics),
           guard let braveUrl = NSURL(string: "firefox-focus://open-url?url=") else { return }

        print("HELLOOO1")

        // From http://stackoverflow.com/questions/24297273/openurl-not-work-in-action-extension
        var responder = self as UIResponder?
        while (responder != nil) {
            print("HELLOOO")
            if responder!.responds(to: #selector(UIApplication.canOpenURL(_:))) {
                responder!.perform(#selector(UIApplication.canOpenURL(_:)), with: braveUrl)
            }
            responder = responder!.next
        }
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
