/* This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class TooltipViewController: UIViewController {
        
    let tooltipView = TooltipView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tooltipView.dismissButton.addTarget(self, action: #selector(tooltipDismissButtonTapped), for: .primaryActionTriggered)
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        preferredContentSize.height = tooltipView.frame.size.height - tooltipView.mainStackView.frame.size.height
    }
            
    func setupLayout() {
        view.addSubview(tooltipView)
        tooltipView.mainStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
        }
    }
    
    func createTooltipPopover(anchoredBy sourceView: UIView, sourceRect: CGRect, viewController: UIViewController) {
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sourceView
        viewController.popoverPresentationController?.sourceRect = sourceRect
        viewController.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        viewController.popoverPresentationController?.delegate = self
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
