import UIKit
import URLBar
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var urlBarView: URLBarView!
    @IBOutlet weak var browsingStateSegmentedControl: UISegmentedControl!
    
    private var cancellables: Set<AnyCancellable> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        urlBarView.viewModel.viewActionPublisher
            .sink { action in
                switch action {
                case .contextMenuTap:
                    print("contextMenuTap")
                    
                case .cancelButtonTap:
                    self.urlBarView.viewModel.currentSelectionSubject
                        .send(.unselected)
                    
                case .backButtonTap:
                    print("backButtonTap")
                    
                case .forwardButtonTap:
                    print("forwardButtonTap")
                    
                case .stopReloadButtonTap:
                    switch self.urlBarView.viewModel.browsingStateSubject.value {
                    case .home:
                        ()
                    case .browsing(let loadingState):
                        switch loadingState {
                        case .stop:
                            self.urlBarView.viewModel.browsingStateSubject
                                .send(.browsing(.refresh))
                        case .refresh:
                            self.urlBarView.viewModel.startBrowsing()
                        }
                    }
                    
                case .deleteButtonTap:
                    self.urlBarView.viewModel.goHome()
                    self.browsingStateSegmentedControl.selectedSegmentIndex = 0
                    
                case .searchTapped:
                    self.urlBarView.viewModel.startBrowsing()
                    
                case .urlBarSelected:
                    self.urlBarView.viewModel.selectURLBar()
                    
                case .urlBarDismissed:
                    self.urlBarView.viewModel.currentSelectionSubject
                        .send(.unselected)
                    
                case .shieldIconTap:
                    print("shieldIconTap")
                case .submit(let text):
                    print(text)
                case .enter(text: let text):
                    print(text)
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        urlBarView.viewModel.selectURLBar()
    }
    
    @IBAction func homeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            urlBarView.viewModel.goHome()
        case 1 :
            urlBarView.viewModel.startBrowsing()
        default:
            break
        }
    }
    @IBAction func connectionSegment(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            urlBarView.viewModel.connectionStateSubject.send(.on(TPPageStats()))
        case 1 :
            urlBarView.viewModel.connectionStateSubject.send(.off)
        case 2:
            urlBarView.viewModel.connectionStateSubject.send(.connectionNotSecure)
        default:
            break
        }
    }
    
    @IBAction func progressChanged(_ sender: UISlider) {
        urlBarView.viewModel.loadingProgresSubject.send(sender.value)
    }
}

