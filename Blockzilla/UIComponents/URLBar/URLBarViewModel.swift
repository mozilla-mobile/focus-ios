// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Combine
import UIKit

public enum URLViewAction {
    case contextMenuTap(anchor: UIButton)
    case backButtonTap
    case forwardButtonTap
    case stopButtonTap
    case reloadButtonTap
    case deleteButtonTap
    case shieldIconButtonTap
    case dragInteractionStarted
    case pasteAndGo
}

public enum ShieldIconStatus: Equatable {
    case on
    case off
    case connectionNotSecure
}

public class URLBarViewModel {
    @Published public var connectionState: ShieldIconStatus = .on
    internal var viewActionSubject = PassthroughSubject<URLViewAction, Never>()
    public var viewActionPublisher: AnyPublisher<URLViewAction, Never> { viewActionSubject.eraseToAnyPublisher() }

}
