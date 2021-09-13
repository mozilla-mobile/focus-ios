import UIKit

class TipsPageViewController: UIViewController {
    enum State {
        case showTips
        case showEmpty(controller: UIViewController)
    }
    
    private var emptyController: UIViewController?
    
    private var tipManager: TipManager
    private var currentIndex: Int = 0
    
    private lazy var pageController: UIPageViewController = {
        let pageController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageController.dataSource = self
        pageController.delegate = self
        pageController.view.backgroundColor = .clear
        return pageController
    }()
    
    init(tipManager: TipManager) {
        self.tipManager = tipManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGray
    }
    
    func setupPageController(with state: State) {
        pageController.removeAsChild()
        emptyController?.removeAsChild()
        
        switch state {
        case .showTips:
            guard let initialVC = tipManager.currentTip.map(TipViewController.init(tip:)) else { return }
            install(pageController, on: self.view)
            self.pageController.setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
            
        case .showEmpty(let controller):
            emptyController = controller
            install(controller, on: self.view)
        }
        
    }
}

extension TipsPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return tipManager.getPreviousTip().map(TipViewController.init(tip:))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return tipManager.getNextTip().map(TipViewController.init(tip:))
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.tipManager.numberOfTips()
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.tipManager.currentTipIndex()
    }
}
