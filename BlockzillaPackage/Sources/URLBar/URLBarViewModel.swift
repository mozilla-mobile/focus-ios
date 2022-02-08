import UIKit
import Combine

public enum URLViewAction {
    case contextMenuTap
    case cancelButtonTap
    case backButtonTap
    case forwardButtonTap
    case stopReloadButtonTap
    case deleteButtonTap
    case searchTapped
    case urlBarSelected
    case urlBarDismissed
    case shieldIconTap
}

public class URLBarViewModel {
    public enum BrowsingState: Equatable {
        public enum LoadingState: Equatable {
            case stop
            case refresh
        }
        case home
        case browsing(LoadingState)
    }
    
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
    }
    
    public enum Device: Equatable {
        case iPhone
        case iPad
        
        init() {
            self = UIDevice.current.userInterfaceIdiom == .phone ? .iPhone : .iPad
        }
    }
    
    internal var viewActionSubject = PassthroughSubject<URLViewAction, Never>()
    public var viewActionPublisher: AnyPublisher<URLViewAction, Never> { viewActionSubject.eraseToAnyPublisher() }
    
    private var currentSelectionSubject = CurrentValueSubject<Selection, Never>(.selected)
    public var currentSelectionPublisher: AnyPublisher<Selection, Never> { currentSelectionSubject.eraseToAnyPublisher() }
    
    private var browsingStateSubject = CurrentValueSubject<BrowsingState, Never>(.home)
    public var browsingStatePublisher: AnyPublisher<BrowsingState, Never> { browsingStateSubject.eraseToAnyPublisher() }
    
    public var connectionStateSubject = CurrentValueSubject<TrackingProtectionStatus, Never>(.on(.empty))
    public var connectionStatePublisher: AnyPublisher<TrackingProtectionStatus, Never> { connectionStateSubject.eraseToAnyPublisher() }
    
    public var loadingProgresSubject = CurrentValueSubject<Float, Never>(0)
    internal var loadingProgresPublisher: AnyPublisher<Float, Never> {
        loadingProgresSubject
        .filter { 0 <= $0 && $0 <= 1 }
        .eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let orientationSubject = NotificationCenter
        .default
        .publisher(for: UIDevice.orientationDidChangeNotification, object: nil)
        .map { _ in
            Orientation()
        }
    
    var statePublisher: AnyPublisher<(BrowsingState, Device, Orientation), Never> {
        Publishers.CombineLatest(browsingStateSubject, orientationSubject)
            .receive(on: DispatchQueue.main)
            .map { browsingState, orientation in
                return (browsingState, Device(), orientation)
            }
            .eraseToAnyPublisher()
    }
    
    public init() {
        viewActionPublisher
            .sink { action in
                switch action {
                case .contextMenuTap:
                    print("contextMenuTap")
                    
                case .cancelButtonTap:
                    self.currentSelectionSubject
                        .send(.unselected)
                    
                case .backButtonTap:
                    print("backButtonTap")
                    
                case .forwardButtonTap:
                    print("forwardButtonTap")
                    
                case .stopReloadButtonTap:
                    switch self.browsingStateSubject.value {
                    case .home:
                        ()
                    case .browsing(let loadingState):
                        switch loadingState {
                        case .stop:
                            self.browsingStateSubject
                                .send(.browsing(.refresh))
                        case .refresh:
                            self.startBrowsing()
                        }
                    }
                    
                case .deleteButtonTap:
                    self.goHome()
                    print("deleteButtonTap")
                    
                case .searchTapped:
                    self.startBrowsing()
                    
                case .urlBarSelected:
                    self.selectURLBar()
                    
                case .urlBarDismissed:
                    self.currentSelectionSubject
                        .send(.unselected)
                    
                case .shieldIconTap:
                    print("shieldIconTap")
                }
            }
            .store(in: &cancellables)
    }
    
    public func selectURLBar() {
        self.currentSelectionSubject
            .send(.selected)
    }
    
    public func startBrowsing() {
        self.browsingStateSubject
            .send(.browsing(.stop))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.browsingStateSubject
                .send(.browsing(.refresh))
        }
    }
    
    public func goHome() {
        self.browsingStateSubject
            .send(.home)
    }
}
