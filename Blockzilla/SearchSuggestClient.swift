/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Alamofire
import Foundation

let SearchSuggestClientErrorDomain = "org.mozilla.firefox.SearchSuggestClient"
let SearchSuggestClientErrorInvalidEngine = 0
let SearchSuggestClientErrorInvalidResponse = 1

/*
 * Clients of SearchSuggestionClient should retain the object during the
 * lifetime of the search suggestion query, as requests are canceled during destruction.
 *
 * Query callbacks that must run even if they are cancelled should wrap their contents in `withExtendendLifetime`.
 */
class SearchSuggestClient {
    fileprivate weak var request: Request?
    private var engine: SearchEngine
    lazy fileprivate var alamofire: SessionManager = {
         let configuration = URLSessionConfiguration.ephemeral
         var defaultHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
         configuration.httpAdditionalHeaders = defaultHeaders
         return SessionManager(configuration: configuration)
     }()

    init(){
        engine = SearchEngineManager(prefs: UserDefaults.standard).activeEngine
    }

    func getSuggestions(_ query: String, callback: @escaping (_ response: [String]?, _ error: NSError?) -> Void) {
        cancelPendingRequest()
        let url = engine.urlForSuggestions(query)
        if url == nil {
            let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidEngine, userInfo: nil)
            callback(nil, error)
            return
        }

        request = alamofire.request(url!)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if let error = response.result.error {
                    callback(nil, error as NSError?)
                    return
                }

                // The response will be of the following format:
                //    ["foobar",["foobar","foobar2000 mac","foobar skins",...]]
                // That is, an array of at least two elements: the search term and an array of suggestions.
                let array = response.result.value as? NSArray
                if array?.count ?? 0 < 2 {
                    let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                    callback(nil, error)
                    return
                }

                if var suggestions = array?[1] as? [String] {
                    if let searchWord = array?[0] as? String {
                        suggestions.insert(searchWord, at: 0)
                    }
                    callback(suggestions, nil)
                    return
                }
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                callback(nil, error)
        }
    }

    func cancelPendingRequest() {
        request?.cancel()
    }
}
