// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Combine

public enum URLViewAction {
    case shieldIconButtonTap
}

public enum ShieldIconStatus: Equatable {
    case on
    case off
    case connectionNotSecure
}

public class URLBarViewModel {
    internal var viewActionSubject = PassthroughSubject<URLViewAction, Never>()
    public var viewActionPublisher: AnyPublisher<URLViewAction, Never> { viewActionSubject.eraseToAnyPublisher() }

    public var connectionStateSubject = CurrentValueSubject<ShieldIconStatus, Never>(.on)
    public var connectionStatePublisher: AnyPublisher<ShieldIconStatus, Never> { connectionStateSubject.eraseToAnyPublisher() }
}
