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
}

public enum ShieldIconStatus: Equatable {
    case on
    case off
    case connectionNotSecure
}

public class URLBarViewModel {

    public enum Orientation: Equatable {
        case portrait
        case landscape

        init() {
            self = UIApplication.shared.orientation?.isPortrait ?? true ? .portrait : .landscape
        }
    }

    public enum Selection: Equatable {
        case selected
        case unselected

        var isSelecting: Bool { self == .selected }
    }

    public enum BrowsingState: Equatable {
        case home
        case browsing

        var isBrowsingMode: Bool { self == .browsing }
    }

    @Published var selectionState = Selection.unselected
    @Published public var browsingState = BrowsingState.home

    internal var viewActionSubject = PassthroughSubject<URLViewAction, Never>()
    public var viewActionPublisher: AnyPublisher<URLViewAction, Never> { viewActionSubject.eraseToAnyPublisher() }

    @Published public var connectionState: ShieldIconStatus = .on
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false
    @Published public var canDelete: Bool = false
    @Published public var isLoading: Bool = false

    private let orientationSubject = NotificationCenter
        .default
        .publisher(for: UIDevice.orientationDidChangeNotification, object: nil)
        .map { _ in
            Orientation()
        }

    var statePublisher: AnyPublisher<(BrowsingState, Orientation), Never> {
        Publishers.CombineLatest($browsingState, orientationSubject)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func resetToDefaults() {
        selectionState = .unselected
        browsingState = .home
        canGoBack = false
        canGoForward = false
        canDelete = false
        isLoading = false
    }
}
