// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension Float {
    static let urlTextOffset: Float = 15
    static let urlBarLayoutPriorityRawValue: Float = 1000
}

extension UIEdgeInsets {
    static let toolbarButtonInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
}

extension CGFloat {
    static let browserToolbarHeight: CGFloat = 44
    static let browserToolbarDisabledOpacity: CGFloat = 0.4
    static let urlBarCornerRadius: CGFloat = 10
    static let collapsedUrlBarHeight: CGFloat = 22
    static let urlBarMargin: CGFloat = 10
    static let urlBarHeightInset: CGFloat = 0
    static let urlBarContainerHeightInset: CGFloat = 10
    static let urlBarTextInset: CGFloat = 30
    static let urlBarWidthInset: CGFloat = 8
    static let urlBarBorderInset: CGFloat = 0
    static let urlBarClearButtonWidth: CGFloat = 20
    static let urlBarClearButtonHeight: CGFloat = 20
    static let deleteButtonOffset: CGFloat = -5
    static let urlBarIconInset: CGFloat = 8
    static let progressBarHeight: CGFloat = 1.5
    static let contextMenuIconSize: CGFloat = 28
    static var barButtonHeight: CGFloat = 36
    static let urlBarHeight: CGFloat = 36
}

extension TimeInterval {
    static let overlayAnimationDuration: TimeInterval = 0.25
    static let urlBarTransitionAnimationDuration: TimeInterval = 0.2
}
