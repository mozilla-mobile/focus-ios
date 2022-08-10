// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

public class URLBarLarge: URLBar {
    fileprivate lazy var leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    fileprivate lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func setupLayout() {
        addSubview(urlBarBackgroundView)
        rightStackView.addArrangedSubview(contextMenuButton)
        urlStackView.addArrangedSubview(shieldIconButton)
        urlStackView.addArrangedSubview(urlTextField)
        stackView.addArrangedSubview(leftStackView)
        stackView.addArrangedSubview(urlStackView)
        stackView.addArrangedSubview(rightStackView)
        addSubview(stackView)
        addSubview(truncatedUrlText)
        addSubview(progressBar)

        stackView.distribution = .equalCentering
        urlStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6).isActive = true

        NSLayoutConstraint.activate([
            truncatedUrlText.centerXAnchor.constraint(equalTo: centerXAnchor),
            truncatedUrlText.heightAnchor.constraint(equalToConstant: .collapsedUrlBarHeight),
            truncatedUrlText.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            urlBarBackgroundView.topAnchor.constraint(equalTo: urlStackView.topAnchor),
            urlBarBackgroundView.leadingAnchor.constraint(equalTo: urlStackView.leadingAnchor),
            urlBarBackgroundView.trailingAnchor.constraint(equalTo: urlStackView.trailingAnchor),
            urlBarBackgroundView.bottomAnchor.constraint(equalTo: urlStackView.bottomAnchor),

            stackView.heightAnchor.constraint(equalToConstant: .urlBarHeight),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),

            progressBar.heightAnchor.constraint(equalToConstant: .progressBarHeight),
            progressBar.topAnchor.constraint(equalTo: bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    override func adaptUI(for browsingState: URLBarViewModel.BrowsingState, orientation: URLBarViewModel.Layout) {
        switch (browsingState, orientation) {
        case (.home, _):
            forwardButton.fadeOut(animated: false)
            backButton.fadeOut(animated: false)
            stopReloadButton.fadeOut(animated: false)
            deleteButton.animateFadeOutFromSuperview()

        case (.browsing, _):
            forwardButton
                .fadeIn(
                    firstDo: { [leftStackView, forwardButton] in
                        leftStackView.prependArrangedSubview(forwardButton)
                    }
                )
            backButton
                .fadeIn(
                    firstDo: { [leftStackView, backButton] in
                        leftStackView.prependArrangedSubview(backButton)
                    }
                )

            stopReloadButton
                .fadeIn(
                    firstDo: { [urlStackView, stopReloadButton] in
                        urlStackView.appendArrangedSubview(stopReloadButton)
                    })

            deleteButton
                .fadeIn(
                    firstDo: { [rightStackView, deleteButton] in
                        rightStackView.prependArrangedSubview(deleteButton)
                    })
        }
    }

    override func adaptUI(for selection: URLBarViewModel.Selection) {
        switch selection {
        case .selected:
            shieldIconButton.fadeOut()
            self.urlTextField.isUserInteractionEnabled = true
            self.urlTextField.becomeFirstResponder()
            self.highlightText(self.urlTextField)

        case .unselected:
            _ = urlTextField.resignFirstResponder()
            urlTextField.isUserInteractionEnabled = true
            shieldIconButton.fadeIn()
        }
    }
}
