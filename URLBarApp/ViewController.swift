import UIKit
import URLBar
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var urlBar: URLBarView!
    
    var cancellable: AnyCancellable?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        urlBar.viewModel.selectURLBar()
    }
    
    @IBAction func homeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            urlBar.viewModel.goHome()
        case 1 :
            urlBar.viewModel.startBrowsing()
        default:
            break
        }
    }
    @IBAction func connectionSegment(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            urlBar.viewModel.connectionStateSubject.send(.on(TPPageStats()))
        case 1 :
            urlBar.viewModel.connectionStateSubject.send(.off)
        case 2:
            urlBar.viewModel.connectionStateSubject.send(.connectionNotSecure)
        default:
            break
        }
    }
    
    @IBAction func progressChanged(_ sender: UISlider) {
        urlBar.viewModel.loadingProgresSubject.send(sender.value)
    }
}

