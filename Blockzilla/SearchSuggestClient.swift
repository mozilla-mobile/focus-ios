/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Alamofire
import Foundation
//import Shared
let SearchSuggestClientErrorDomain = "org.mozilla.firefox.SearchSuggestClient"
let SearchSuggestClientErrorInvalidEngine = 0
let SearchSuggestClientErrorInvalidResponse = 1

private let TypeSuggest = "application/x-suggestions+json"

extension CharacterSet {
    public static let URLAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
    public static let SearchTermsAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789*-_.")
}

class SuggestionCreator {
    fileprivate let suggestTemplate: String?
    
    fileprivate let SearchTermComponent = "{searchTerms}"
    fileprivate let LocaleTermComponent = "{moz:locale}"
    
    init(engine: SearchEngine) {
        //self.suggestTemplate = suggestTemplate
        self.suggestTemplate = "https://www.google.com/complete/search?client=firefox&q={searchTerms}"
    }
    
    /**
     * Returns the search suggestion URL for the given query.
     */
    func suggestURLForQuery(_ query: String) -> URL? {
        if let suggestTemplate = suggestTemplate {
            if let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .SearchTermsAllowed) {
                // Escape the search template as well in case it contains not-safe characters like symbols
                let templateAllowedSet = NSMutableCharacterSet()
                templateAllowedSet.formUnion(with: .URLAllowed)
                
                // Allow brackets since we use them in our template as our insertion point
                templateAllowedSet.formUnion(with: CharacterSet(charactersIn: "{}"))
                
                if let encodedSearchTemplate = suggestTemplate.addingPercentEncoding(withAllowedCharacters: templateAllowedSet as CharacterSet) {
                    let localeString = Locale.current.identifier
                    let urlString = encodedSearchTemplate
                        .replacingOccurrences(of: SearchTermComponent, with: escapedQuery, options: .literal, range: nil)
                        .replacingOccurrences(of: LocaleTermComponent, with: localeString, options: .literal, range: nil)
                    return URL(string: urlString)
                }
            }
        }
        return nil
    }
}


/*
 * Clients of SearchSuggestionClient should retain the object during the
 * lifetime of the search suggestion query, as requests are canceled during destruction.
 *
 * Query callbacks that must run even if they are cancelled should wrap their contents in `withExtendendLifetime`.
 */
class SearchSuggestClient {
    fileprivate let suggestionCreator: SuggestionCreator
    fileprivate weak var request: Request?
    
     lazy fileprivate var alamofire: SessionManager = {
         let configuration = URLSessionConfiguration.ephemeral
         var defaultHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
         configuration.httpAdditionalHeaders = defaultHeaders
         return SessionManager(configuration: configuration)
     }()
    
    init(){
        self.suggestionCreator = SuggestionCreator(engine: SearchEngineManager(prefs: UserDefaults.standard).activeEngine)
    }
    
    func getSuggestions(_ query: String, callback: @escaping (_ response: [String]?, _ error: NSError?) -> Void) {
        cancelPendingRequest()
        let url = suggestionCreator.suggestURLForQuery(query)
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
                
                let suggestions = array?[1] as? [String]
                if suggestions == nil {
                    let error = NSError(domain: SearchSuggestClientErrorDomain, code: SearchSuggestClientErrorInvalidResponse, userInfo: nil)
                    callback(nil, error)
                    return
                }
                
                callback(suggestions!, nil)
        }
        
    }
    
    func cancelPendingRequest() {
        request?.cancel()
    }
}
