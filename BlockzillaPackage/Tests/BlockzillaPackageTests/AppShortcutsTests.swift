//
//  AppShortcutsTests.swift
//  
//
//  Created by razvan.litianu on 28.04.2022.
//

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

class AppShortcutsTests: XCTestCase {

    var sut: ShortcutsManager!

    override func setUp() {
        sut = ShortcutsManager.shared
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "Shortcuts")
        sut = nil
    }

    func testAddingShortcutIsAddedToShortcutsList() throws {
        // Given
        let shortcut = Shortcut(url: URL(string: "www.google.com")!)

        // When
        sut.add(shortcut: shortcut)

        // Then
        XCTAssertEqual(sut.shortcuts.count, 1)
    }
}
