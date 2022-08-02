/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class BrowserToolbar: UIView {
    private let backgroundLoading = GradientBackgroundView()
    private let backgroundDark = UIView()
    private let backgroundBright = UIView()
    private let stackView = UIStackView()

    private lazy var backButton: InsetButton = {
        let backButton = InsetButton()
        backButton.setImage(#imageLiteral(resourceName: "icon_back_active"), for: .normal)
        backButton.addTarget(self, action: #selector(didPressBack), for: .touchUpInside)
        backButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        backButton.accessibilityLabel = UIConstants.strings.browserBack
        backButton.isEnabled = false
        return backButton
    }()

    private lazy var forwardButton: InsetButton = {
        let forwardButton = InsetButton()
        forwardButton.setImage(#imageLiteral(resourceName: "icon_forward_active"), for: .normal)
        forwardButton.addTarget(self, action: #selector(didPressForward), for: .touchUpInside)
        forwardButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        forwardButton.accessibilityLabel = UIConstants.strings.browserForward
        forwardButton.isEnabled = false
        return forwardButton
    }()

    private lazy var deleteButton: InsetButton = {
        let deleteButton = InsetButton()
        deleteButton.setImage(#imageLiteral(resourceName: "icon_delete"), for: .normal)
        deleteButton.addTarget(self, action: #selector(didPressDelete), for: .touchUpInside)
        deleteButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        deleteButton.accessibilityIdentifier = "URLBar.deleteButton"
        deleteButton.isEnabled = false
        return deleteButton
    }()

    private lazy var contextMenuButton: InsetButton = {
        let contextMenuButton = InsetButton()
        contextMenuButton.setImage(#imageLiteral(resourceName: "icon_hamburger_menu"), for: .normal)
        contextMenuButton.tintColor = .primaryText
        if #available(iOS 14.0, *) {
            contextMenuButton.showsMenuAsPrimaryAction = true
            contextMenuButton.menu = UIMenu(children: [])
            contextMenuButton.addTarget(self, action: #selector(didPressContextMenu), for: .menuActionTriggered)
        } else {
            contextMenuButton.addTarget(self, action: #selector(didPressContextMenu), for: .touchUpInside)
        }
        contextMenuButton.accessibilityLabel = UIConstants.strings.browserSettings
        contextMenuButton.accessibilityIdentifier = "HomeView.settingsButton"
        contextMenuButton.contentEdgeInsets = UIConstants.layout.toolbarButtonInsets
        contextMenuButton.imageView?.snp.makeConstraints { $0.size.equalTo(UIConstants.layout.contextMenuIconSize) }
        return contextMenuButton
    }()

    public var contextMenuButtonAnchor: UIView { contextMenuButton }
    public var deleteButtonAnchor: UIView { deleteButton }

    init() {
        super.init(frame: CGRect.zero)

        let background = UIView()
        background.backgroundColor = .foundation
        addSubview(background)

        stackView.distribution = .fillEqually

        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(forwardButton)
        stackView.addArrangedSubview(deleteButton)
        stackView.addArrangedSubview(contextMenuButton)
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.right.left.equalTo(self)
            make.height.equalTo(UIConstants.layout.browserToolbarHeight)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }

        background.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var delegate: BrowserToolsetDelegate?

    var canDelete: Bool = false {
        didSet {
            deleteButton.isEnabled = canDelete
            deleteButton.alpha = canDelete ? 1 : UIConstants.layout.browserToolbarDisabledOpacity
        }
    }

    var canGoBack: Bool = false {
        didSet {
            backButton.isEnabled = canGoBack
            backButton.alpha = canGoBack ? 1 : UIConstants.layout.browserToolbarDisabledOpacity
        }
    }

    var canGoForward: Bool = false {
        didSet {
            forwardButton.isEnabled = canGoForward
            forwardButton.alpha = canGoForward ? 1 : UIConstants.layout.browserToolbarDisabledOpacity
        }
    }

    @objc private func didPressBack() {
        delegate?.browserToolsetDidPressBack()
    }

    @objc private func didPressForward() {
        delegate?.browserToolsetDidPressForward()
    }

    @objc func didPressDelete() {
        if canDelete {
            delegate?.browserToolsetDidPressDelete()
        }
    }

    @objc private func didPressContextMenu(_ sender: InsetButton) {
        delegate?.browserToolsetDidPressContextMenu(menuButton: sender)
    }
}
