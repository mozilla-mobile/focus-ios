/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */


import Foundation

struct textSearched{
    var text: String
    var isCurrentSearch: Bool
}

class SearchHistoryUtils {
    static func pushSearchToStack(with searchedText: String) {
        var currentStack = [textSearched]()

        if let encodedCurrentStack = UserDefaults.standard.value(forKey: "searchedHistory") as? Data {
            currentStack = NSKeyedUnarchiver.unarchiveObject(with: encodedCurrentStack) as? [textSearched] ?? []

            for index in 0..<currentStack.count {
                currentStack[index].isCurrentSearch = false
            }
        }

        currentStack.append(textSearched(text: searchedText, isCurrentSearch: true))

        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: currentStack), forKey: "searchedHistory")
    }

    static func pullSearchFromStack() -> String? {
        let currentStack = UserDefaults.standard.value(forKey: "searchedHistory") as? [textSearched] ?? []

        for search in currentStack {
            if search.isCurrentSearch {
                return search.text
            }
        }

        return ""
    }

    // go back
    static func goFoward() {
        var currentStack = UserDefaults.standard.value(forKey: "searchedHistory") as? [textSearched] ?? []

        for index in 0..<currentStack.count {
            if (currentStack[index].isCurrentSearch) {

                currentStack[index + 1].isCurrentSearch = true
                currentStack[index].isCurrentSearch = false
            }
        }
    }

    // go foward
    static func goBack() {
        var currentStack = UserDefaults.standard.value(forKey: "searchedHistory") as? [textSearched] ?? []

        for index in 0..<currentStack.count {
            if (currentStack[index].isCurrentSearch) {

                currentStack[index - 1].isCurrentSearch = true
                currentStack[index].isCurrentSearch = false
            }
        }

    }
}
