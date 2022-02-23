/* This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class TooltipViewController: UIViewController {
        
    private let tooltipView = TooltipView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tooltipView.dismissButton.addTarget(self, action: #selector(tooltipDismissButtonTapped), for: .primaryActionTriggered)
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        preferredContentSize.height = tooltipView.frame.size.height - tooltipView.mainStackView.frame.size.height
    }
            
    private func setupLayout() {
        view.addSubview(tooltipView)
        tooltipView.mainStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
        }
    }
    
    func configure(anchoredBy sourceView: UIView) {
        modalPresentationStyle = .popover
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY + 10, width: 0, height: 0)
        popoverPresentationController?.permittedArrowDirections = [.up, .down]
        popoverPresentationController?.delegate = self
    }
    
    func set(title: String = "", body: String) {
        tooltipView.set(title: title, body: body)
    }
    
    @objc func tooltipDismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension TooltipViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}