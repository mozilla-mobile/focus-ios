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

    @Published public var connectionState: ShieldIconStatus = .on
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false
    @Published public var canDelete: Bool = false
    @Published public var isLoading: Bool = false
}
