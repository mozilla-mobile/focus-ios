/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

protocol ScrollViewControllerDelegate: class {
    func scrollViewController(scrollViewController: ScrollViewController, didUpdatePageCount count: Int)
    func scrollViewController(scrollViewController: ScrollViewController, didUpdatePageIndex index: Int)
    func scrollViewController(scrollViewController: ScrollViewController, didDismissSlideDeck bool: Bool)
}

final class ScrollViewController: UIPageViewController {

    private var slides: [UIImage] = []
    private var orderedViewControllers: [UIViewController] = []
    weak var scrollViewControllerDelegate: ScrollViewControllerDelegate?

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dataSource = self
        delegate = self

        setupCardViews()

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }

        scrollViewControllerDelegate?.scrollViewController(scrollViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }

    private func setupCardViews() {
        let cardViewModels = [CardViewModel(title: UIConstants.strings.CardTitleWelcome, text: UIConstants.strings.CardTextWelcome, image: UIImageView(image: UIImage(named: IntroViewControllerUX.CardSlides[0])), isLast: false),
        CardViewModel(title: UIConstants.strings.CardTitleSearch, text: UIConstants.strings.CardTextSearch, image: UIImageView(image: UIImage(named: IntroViewControllerUX.CardSlides[1])), isLast: false),
        CardViewModel(title: UIConstants.strings.CardTitleHistory, text: UIConstants.strings.CardTextHistory, image: UIImageView(image: UIImage(named: IntroViewControllerUX.CardSlides[2])), isLast: true)]

        cardViewModels.forEach { cardModel in
            let viewController = UIViewController()
            let cardView = CardView(model: cardModel)
            cardView.delegate = self

            viewController.view.backgroundColor = .clear
            viewController.view.addSubview(cardView)

            cardView.snp.makeConstraints { (make) -> Void in
                make.center.equalTo(viewController.view)
                make.width.equalTo(IntroViewControllerUX.Width).priority(.high)
                make.height.equalTo(IntroViewControllerUX.Height)
                make.leading.greaterThanOrEqualTo(viewController.view).offset(UIConstants.layout.introViewOffset).priority(.required)
                make.trailing.lessThanOrEqualTo(viewController.view).offset(UIConstants.layout.introViewOffset).priority(.required)
            }

            orderedViewControllers.append(viewController)
        }
    }

    fileprivate func startBrowsing() {
        scrollViewControllerDelegate?.scrollViewController(scrollViewController: self, didDismissSlideDeck: true)
    }

    fileprivate func changePage(direction: UIPageViewController.NavigationDirection) {
        guard let currentViewController = viewControllers?.first, let nextViewController = direction == .forward ?
            dataSource?.pageViewController(self, viewControllerAfter: currentViewController):
            dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }

        guard let newIndex = orderedViewControllers.index(of: nextViewController) else { return }

        setViewControllers([nextViewController], direction: direction, animated: true, completion: nil)
        scrollViewControllerDelegate?.scrollViewController(scrollViewController: self, didUpdatePageIndex: newIndex)
    }
}

// MARK: - PageControlDelegate

extension ScrollViewController: PageControlDelegate {

    func incrementPage(_ pageControl: PageControl) {
        changePage(direction: .forward)
    }

    func decrementPage(_ pageControl: PageControl) {
        changePage(direction: .reverse)
    }
}

// MARK: - UIPageViewControllerDelegate

extension ScrollViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            scrollViewControllerDelegate?.scrollViewController(scrollViewController: self, didUpdatePageIndex: index)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension ScrollViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard
            orderedViewControllersCount != nextIndex,
            orderedViewControllersCount > nextIndex else {
                return nil
        }

        return orderedViewControllers[nextIndex]
    }
}

// MARK: - CardViewDelegate

extension ScrollViewController: CardViewDelegate {
    func cardView(_ cardView: CardView, didTapButton button: UIButton) {
        let model = cardView.model
        model.isLast ? startBrowsing() : changePage(direction: .forward)
    }
}
