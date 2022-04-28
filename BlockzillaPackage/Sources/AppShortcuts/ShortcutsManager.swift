/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

public protocol ShortcutsManagerDelegate: AnyObject {
    func shortcutsDidUpdate()
    func shortcutDidUpdate(shortcut: Shortcut)
}

public class ShortcutsManager {
    let shortcutsKey = "Shortcuts"
    public static let shared = ShortcutsManager()
    
    public private(set) var shortcuts = [Shortcut]()
    
    public weak var delegate: ShortcutsManagerDelegate?

    private init() {
        loadShortcuts()
    }

    private func canSave(shortcut: Shortcut) -> Bool {
        shortcuts.count < Self.maximumNumberOfShortcuts && !isSaved(shortcut: shortcut)
    }
    
    private func saveShortcuts() {
        if let encoded = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(encoded, forKey: "Shortcuts")
        }
        loadShortcuts()
    }
    
    private func loadShortcuts() {
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
}

public extension ShortcutsManager {
    func add(shortcut: Shortcut) {
        if canSave(shortcut: shortcut) {
            shortcuts.append(shortcut)
            saveShortcuts()
            delegate?.shortcutsDidUpdate()
        }
    }
    
    func remove(shortcut: Shortcut) {
        if let index = shortcuts.firstIndex(of: shortcut) {
            shortcuts.remove(at: index)
            saveShortcuts()
            delegate?.shortcutsDidUpdate()
        }
    }
    
    func rename(shortcut: Shortcut, newName: String) {
        var renamedShortcut = shortcut
        renamedShortcut.name = newName
        if let index = shortcuts.firstIndex(of: shortcut), renamedShortcut.name != shortcuts[index].name {
            shortcuts[index] = renamedShortcut
            saveShortcuts()
            delegate?.shortcutDidUpdate(shortcut: shortcuts[index])
        }
    }
    
    func isSaved(shortcut: Shortcut) -> Bool {
        shortcuts.contains(shortcut) ? true : false
    }
}

public extension ShortcutsManager {
    static let maximumNumberOfShortcuts = 4
}
