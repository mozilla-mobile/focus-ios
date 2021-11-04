/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

public struct Metadata: Codable {
    public let title: String?
    public let language: String?
    public let url: String
    public let provider: String?
    public let icon: String?
}


class MetadataParserHelper {
    
    enum MetadataError: Swift.Error {
        case missingMetadata
    }

    static func getMetadata(for webview: WKWebView, completion: @escaping (Result<Metadata, Error>) -> Void) {
        // Get the metadata out of the page-metadata-parser, and into a type safe struct as soon
        // as possible.
        
        webview.evaluateJavascriptInDefaultContentWorld("__firefox__.metadata && __firefox__.metadata.getMetadata()") { result, error in
            let metadata = result
                .flatMap { try? JSONSerialization.data(withJSONObject: $0) }
                .flatMap { try? JSONDecoder().decode(Metadata.self, from: $0) }
            
            if let metadata = metadata {
                completion(.success(metadata))
            } else if let error = error {
                completion(.error(error))
            } else {
                completion(.error(MetadataError.missingMetadata))
            }
            
        }
    }
}
