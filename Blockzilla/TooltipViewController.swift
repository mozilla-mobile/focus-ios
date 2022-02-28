/* This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class TooltipViewController: UIViewController {
        
    private let tooltipView = TooltipView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        tooltipView.delegate = self
        preferredContentSize = tooltipView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
            
    private func setupLayout() {
        view.addSubview(tooltipView)
        tooltipView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(anchoredBy sourceView: UIView, sourceRect: CGRect) {
        modalPresentationStyle = .popover
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect
        popoverPresentationController?.permittedArrowDirections = [.up, .down]
        popoverPresentationController?.delegate = self
    }
    
    func set(title: String = "", body: String) {
        tooltipView.set(title: title, body: body)
    }
    
    @objc func didTapTooltipDismissButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - Delegates
extension TooltipViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TooltipViewController: TooltipViewDelegate {
    func didTapTooltipDismissButton() {
        dismiss(animated: true)
    }
}
