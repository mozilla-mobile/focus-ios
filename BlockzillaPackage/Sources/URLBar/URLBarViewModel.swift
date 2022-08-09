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

        public var isSelecting: Bool { self == .selected }
    }

    public enum BrowsingState: Equatable {
        case home
        case browsing

        public var isBrowsingMode: Bool { self == .browsing }
    }

    @Published public var selectionState = Selection.unselected
    @Published public var browsingState = BrowsingState.home

    internal var viewActionSubject = PassthroughSubject<URLViewAction, Never>()
    public var viewActionPublisher: AnyPublisher<URLViewAction, Never> { viewActionSubject.eraseToAnyPublisher() }

    @Published public var connectionState: ShieldIconStatus = .on
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false
    @Published public var canDelete: Bool = false
    @Published public var isLoading: Bool = false
    public var userInputText: String?
    @Published public var url: URL?

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

    public func resetToDefaults() {
        selectionState = .unselected
        browsingState = .home
        canGoBack = false
        canGoForward = false
        canDelete = false
        isLoading = false
    }

    let strings: URLBarStrings
    lazy var domainCompletion = DomainCompletion(
        completionSources: [
            TopDomainsCompletionSource(enableDomainAutocomplete: enableDomainAutocomplete),
            CustomCompletionSource(
                enableCustomDomainAutocomplete: enableCustomDomainAutocomplete,
                getCustomDomainSetting: getCustomDomainSetting,
                setCustomDomainSetting: setCustomDomainSetting)
        ]
    )

    var enableCustomDomainAutocomplete: () -> Bool
    var getCustomDomainSetting: () -> AutoCompleteSuggestions
    var setCustomDomainSetting: ([String]) -> Void
    var enableDomainAutocomplete: () -> Bool

    public init(
        strings: URLBarStrings,
        enableCustomDomainAutocomplete: @escaping () -> Bool,
        getCustomDomainSetting: @escaping () -> AutoCompleteSuggestions,
        setCustomDomainSetting: @escaping ([String]) -> Void,
        enableDomainAutocomplete: @escaping () -> Bool
    ) {
        self.strings = strings
        self.enableCustomDomainAutocomplete = enableCustomDomainAutocomplete
        self.getCustomDomainSetting = getCustomDomainSetting
        self.setCustomDomainSetting = setCustomDomainSetting
        self.enableDomainAutocomplete = enableDomainAutocomplete
    }
}

public struct URLBarStrings {
    public init(autocompleteAddCustomUrlError: String, urlTextPlaceholder: String, browserBack: String, browserForward: String, browserSettings: String, browserStop: String, browserReload: String, copyMenuButton: String, urlPasteAndGo: String) {
        self.autocompleteAddCustomUrlError = autocompleteAddCustomUrlError
        self.urlTextPlaceholder = urlTextPlaceholder
        self.browserBack = browserBack
        self.browserForward = browserForward
        self.browserSettings = browserSettings
        self.browserStop = browserStop
        self.browserReload = browserReload
        self.copyMenuButton = copyMenuButton
        self.urlPasteAndGo = urlPasteAndGo
    }

    var autocompleteAddCustomUrlError: String
    var urlTextPlaceholder: String
    var browserBack: String
    var browserForward: String
    var browserSettings: String
    var browserStop: String
    var browserReload: String
    var copyMenuButton: String
    var urlPasteAndGo: String
}
