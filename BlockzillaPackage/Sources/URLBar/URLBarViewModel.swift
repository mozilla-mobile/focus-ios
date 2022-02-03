import UIKit
import Combine

public class URLBarViewModel {
    public enum BrowsingState: Equatable {
        case home
        case browsing
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
    
    
    public var currentSelection = CurrentValueSubject<Selection, Never>(.selected)
    public var browsingState = CurrentValueSubject<BrowsingState, Never>(.home)
    private var cancellables: Set<AnyCancellable> = []
    
    private let orientationSubject = NotificationCenter
        .default
        .publisher(for: UIDevice.orientationDidChangeNotification, object: nil)
        .map { _ in
            Orientation()
        }
    
    var statePublisher: AnyPublisher<(BrowsingState, Device, Orientation), Never> {
        Publishers.CombineLatest(browsingState, orientationSubject)
            .receive(on: DispatchQueue.main)
            .map { browsingState, orientation in
                return (browsingState, Device(), orientation)
            }
            .eraseToAnyPublisher()
    }
    public init() {}
}
