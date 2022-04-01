/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

struct Shortcut: Equatable, Codable {
    var url: URL
    var name: String
    
    init(url: URL, name: String = "") {
        self.url = url
        self.name = name.isEmpty ? Shortcut.defaultName(for: url) : name
    }
    
    private static func defaultName(for url: URL) -> String {
        if let host = url.host {
            var shortUrl = host.replacingOccurrences(of: "www.", with: "")
            if shortUrl.hasPrefix("mobile.") {
                shortUrl = shortUrl.replacingOccurrences(of: "mobile.", with: "")
            }
            if shortUrl.hasPrefix("m.") {
                shortUrl = shortUrl.replacingOccurrences(of: "m.", with: "")
            }
            if let domain = shortUrl.components(separatedBy: ".").first?.capitalized {
                return domain
            }
        }
        return ""
    }
}

protocol ShortcutsManagerDelegate: AnyObject {
    func shortcutsUpdated()
    func shortcutUpdated(shortcut: Shortcut, newName: String)
}

class ShortcutsManager {
    
    enum ShortcutsState {
        case createShortcutViews
        case onHomeView
        case editingURL(text: String)
        case activeURLBar
        case dismissedURLBar
    }
    
    @Published var shortcutsState: ShortcutsState?
    
    let shortcutsKey = "Shortcuts"
    static let shared = ShortcutsManager()
    private var shortcuts = [Shortcut]()
    var numberOfShortcuts: Int {
        shortcuts.count
    }
    weak var delegate: ShortcutsManagerDelegate?
    
    init() {
        getAllShortcuts()
    }
    
    private func getAllShortcuts() {
        if let storedObjItem = UserDefaults.standard.object(forKey: "Shortcuts") {
            do {
                let decodedShortcuts = try JSONDecoder().decode([Shortcut].self, from: storedObjItem as! Data)
                print("Retrieved items: \(decodedShortcuts)")
                shortcuts = decodedShortcuts
            } catch let error {
                print(error)
            }
        }
    }
    
    private func saveShortcuts() {
        if let encoded = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: "Shortcuts")
        }
        getAllShortcuts()
    }
    
    func addToShortcuts(shortcut: Shortcut) {
        if canSave(shortcut: shortcut) {
            shortcuts.append(shortcut)
            saveShortcuts()
            delegate?.shortcutsUpdated()
        }
    }
    
    func removeFromShortcuts(shortcut: Shortcut) {
        if let index = shortcuts.firstIndex(of: shortcut) {
            shortcuts.remove(at: index)
            saveShortcuts()
            delegate?.shortcutsUpdated()
        }
    }
    
    func rename(shortcut: Shortcut, newName: String) {
        var renamedShortcut = shortcut
        renamedShortcut.name = newName
        if let index = shortcuts.firstIndex(of: shortcut), renamedShortcut.name != shortcuts[index].name {
            shortcuts[index] = renamedShortcut
            saveShortcuts()
            delegate?.shortcutUpdated(shortcut: shortcuts[index], newName: newName)
        }
    }
    
    func shortcutAt(index: Int) -> Shortcut {
        shortcuts[index]
    }
    
    func isSaved(shortcut: Shortcut) -> Bool {
        shortcuts.contains(shortcut) ? true : false
    }
    
    func canSave(shortcut: Shortcut) -> Bool {
        shortcuts.count < UIConstants.maximumNumberOfShortcuts && !isSaved(shortcut: shortcut)
    }
}
