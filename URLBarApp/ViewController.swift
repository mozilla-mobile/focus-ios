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

    @IBAction func browse(_ sender: Any) {
        urlBar.viewModel.startBrowsing()
    }
    
    @IBAction func home(_ sender: Any) {
        urlBar.viewModel.goHome()
    }
    
}

