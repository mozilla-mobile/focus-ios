/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest
import AppShortcuts

class MockShortcutDelegate: ShortcutsManagerDelegate {
    var shortcutsDidUpdateTrigger = false
    var updatedShortcut: Shortcut?

    func shortcutsDidUpdate() {
        shortcutsDidUpdateTrigger = true
    }

    func shortcutDidUpdate(shortcut: Shortcut) {
        updatedShortcut = shortcut
    }
}

class MockPersister: ShortcutsPersister {
    func save(shortcuts: [Shortcut]) {

    }

    func load() -> [Shortcut] {
        return []
    }
}

class AppShortcutsTests: XCTestCase {

    var sut: ShortcutsManager!

    override func setUp() {
        sut = ShortcutsManager(persister: MockPersister())
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "Shortcuts")
        sut = nil
    }

    func testAddingShortcutIsAddedToShortcutsList() {
        // Given
        let shortcut = Shortcut(url: URL(string: "https://www.google.com")!)

        // When
        sut.add(shortcut: shortcut)

        // Then
        XCTAssertEqual(sut.shortcuts.count, 1)
    }

    func testAddingTheSameShortcutWillNotShowTwice() {
        // Given
        let shortcut = Shortcut(url: URL(string: "https://www.google.com")!)

        // When
        sut.add(shortcut: shortcut)
        sut.add(shortcut: shortcut)

        // Then
        XCTAssertEqual(sut.shortcuts.count, 1)
    }

    func testAddingShortcutTriggersShortcutsDidUpdate() {
        // Given
        let shortcut = Shortcut(url: URL(string: "https://www.google.com")!)
        let delegate = MockShortcutDelegate()
        sut.delegate = delegate

        // When
        sut.add(shortcut: shortcut)

        // Then
        XCTAssertEqual(sut.shortcuts.count, 1)
        XCTAssertTrue(delegate.shortcutsDidUpdateTrigger)
    }

    func testRenamingShortcuTriggersShortcutViewUpdate() {
        // Given
        let shortcut = Shortcut(url: URL(string: "https://www.google.com")!)
        let delegate = MockShortcutDelegate()
        sut.delegate = delegate

        // When
        sut.add(shortcut: shortcut)
        sut.rename(shortcut: shortcut, newName: "TestGoogle")

        // Then
        XCTAssertEqual(sut.shortcuts.count, 1)
        XCTAssertEqual(delegate.updatedShortcut?.name, "TestGoogle")
    }
}
