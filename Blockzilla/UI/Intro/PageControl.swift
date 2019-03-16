/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

protocol PageControlDelegate: class {
    func incrementPage(_ pageControl: PageControl)
    func decrementPage(_ pageControl: PageControl)
}

final class PageControl: NSObject {

    var stack = UIStackView()
    weak var delegate: PageControlDelegate?

    var currentPage = 0 {
        didSet {
            updateButtonsAppearance(currentPage)
        }
    }

    var numberOfPages = 0 {
        didSet {
            addPages()
            currentPage = 0
        }
    }

    private var buttons: [UIButton] {
        guard let arrangedButtons = stack.arrangedSubviews as? [UIButton] else { return [] }
        return arrangedButtons
    }

    private func addPages() {
        guard numberOfPages != 0 else {
            return
        }

        let buttons = makeButtons()

        stack = UIStackView(arrangedSubviews: buttons)
        stack.spacing = 20
        stack.distribution = .equalCentering
        stack.alignment = .center
        stack.accessibilityIdentifier = "Intro.stackView"
    }

    private func makeButtons() -> [UIButton] {
        var buttons: [UIButton] = []

        for _ in 0..<numberOfPages {
            let button = UIButton(frame: UIConstants.layout.introViewButtonFrame)
            button.setImage(UIImage(imageLiteralResourceName: "page_indicator"), for: .normal)
            button.addTarget(self, action: #selector(selected(sender:)), for: .touchUpInside)
            buttons.append(button)
        }

        return buttons
    }

    private func updateButtonsAppearance(_ index: Int) {
        guard !buttons.isEmpty else { return }

        for (i, button) in buttons.enumerated() {
            button.isSelected = i == index ? true : false
            button.alpha = i == index ? 1 : 0.3
        }
    }

    @objc private func selected(sender: UIButton) {
        guard let buttonIndex = buttons.index(of: sender) else {
            return
        }

        buttonIndex > currentPage ? goNext() : goPrevious()
    }

    func goNext() {
        currentPage += 1
        delegate?.incrementPage(self)
    }

    func goPrevious() {
        currentPage -= 1
        delegate?.decrementPage(self)
    }
}
