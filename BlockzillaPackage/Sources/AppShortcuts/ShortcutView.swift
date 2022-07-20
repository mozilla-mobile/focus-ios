/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import DesignSystem
import UIComponents
import UIHelpers

public protocol ShortcutViewDelegate: AnyObject {
    func shortcutTapped(shortcut: Shortcut)
    func removeFromShortcutsAction(shortcut: Shortcut)
    func rename(shortcut: Shortcut)
    func dismissShortcut()
}

public class ShortcutView: UIView {
    public var contextMenuIsDisplayed = false
    public private(set) var shortcut: Shortcut
    public weak var delegate: ShortcutViewDelegate?

    public private(set) lazy var outerView: UIView = {
        let outerView = UIView()
        outerView.backgroundColor = .above
        outerView.accessibilityIdentifier = "outerView"
        outerView.layer.cornerRadius = 8
        outerView.translatesAutoresizingMaskIntoConstraints = false
        return outerView
    }()

    private lazy var innerView: UIView = {
        let innerView = UIView()
        innerView.backgroundColor = .foundation
        innerView.layer.cornerRadius = 4
        innerView.translatesAutoresizingMaskIntoConstraints = false
        return innerView
    }()

    private lazy var letterLabel: UILabel = {
        let letterLabel = UILabel()
        letterLabel.textColor = .primaryText
        letterLabel.font = .title20
        letterLabel.translatesAutoresizingMaskIntoConstraints = false
        return letterLabel
    }()

    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = .primaryText
        nameLabel.font = .footnote12
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    private lazy var faviImageView: AsyncImageView = {
        let image = AsyncImageView()
        image.layer.cornerRadius = 4
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    public struct LayoutConfiguration {
        public var width: CGFloat
        public var height: CGFloat
        public var inset: CGFloat

        public static let iPad = LayoutConfiguration(
            width: .shortcutViewWidthIPad,
            height: .shortcutViewHeightIPad,
            inset: .shortcutViewInnerDimensionIPad
        )
        public static let `default` = LayoutConfiguration(
            width: .shortcutViewWidth,
            height: .shortcutViewHeight,
            inset: .shortcutViewInnerDimension
        )
    }

    private var faviconWithLetter: (String) -> UIImage?

    public init(shortcut: Shortcut,
                layoutConfiguration: LayoutConfiguration = .default) {
        self.shortcut = shortcut
        self.faviconWithLetter = { letter in
            FaviIconGenerator.shared.faviconImage(capitalLetter: letter, textColor: .primaryText, backgroundColor: .foundation)
        }

        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: 0, y: 0, width: layoutConfiguration.width, height: layoutConfiguration.height)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tap)

        addSubview(outerView)

        NSLayoutConstraint.activate([
            outerView.widthAnchor.constraint(equalToConstant: layoutConfiguration.width),
            outerView.heightAnchor.constraint(equalToConstant: layoutConfiguration.width),
            outerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            outerView.topAnchor.constraint(equalTo: topAnchor)
        ])

        let capital = shortcut.name.first.map(String.init)?.capitalized
        if let url = shortcut.imageURL {
            outerView.addSubview(faviImageView)

            NSLayoutConstraint.activate([
                faviImageView.widthAnchor.constraint(equalToConstant: layoutConfiguration.inset),
                faviImageView.heightAnchor.constraint(equalToConstant: layoutConfiguration.inset),
                faviImageView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor),
                faviImageView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor)
            ])

            let shortcutImage = capital.flatMap(faviconWithLetter) ?? .defaultFavicon
            faviImageView.load(imageURL: url, defaultImage: shortcutImage)
        } else {
            outerView.addSubview(innerView)

            NSLayoutConstraint.activate([
                innerView.widthAnchor.constraint(equalToConstant: layoutConfiguration.inset),
                innerView.heightAnchor.constraint(equalToConstant: layoutConfiguration.inset),
                innerView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor),
                innerView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor)
            ])

            letterLabel.text = capital
            innerView.addSubview(letterLabel)

            NSLayoutConstraint.activate([
                letterLabel.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
                letterLabel.centerYAnchor.constraint(equalTo: innerView.centerYAnchor)
            ])
        }

        nameLabel.text = shortcut.name
        addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: outerView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        delegate?.shortcutTapped(shortcut: shortcut)
    }

    public func rename(shortcut: Shortcut) {
        self.shortcut = shortcut
        nameLabel.text = shortcut.name
        letterLabel.text = shortcut.name.first.map(String.init)?.capitalized
    }
}

// MARK: Constants

fileprivate extension CGFloat {
    static let shortcutViewWidth: CGFloat = 60
    static let shortcutViewWidthIPad: CGFloat = 80
    static let shortcutViewInnerDimension: CGFloat = 36
    static let shortcutViewInnerDimensionIPad: CGFloat = 48
    static let shortcutViewHeight: CGFloat = 84
    static let shortcutViewHeightIPad: CGFloat = 100
}
