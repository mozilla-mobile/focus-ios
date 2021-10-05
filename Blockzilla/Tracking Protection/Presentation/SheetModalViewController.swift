/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

class SheetModalViewController: UIViewController {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        view.layer.cornerRadius = metrics.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Float(metrics.shadowOpacity)
        view.layer.shadowRadius = metrics.shadowRadius
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.clipsToBounds = true
        return view
    }()
    
    private let containerViewController: UIViewController
    private let metrics: SheetMetrics
    
    init(containerViewController: UIViewController, metrics: SheetMetrics = .default) {
        self.containerViewController = containerViewController
        self.metrics = metrics
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var minimumDimmingAlpha: CGFloat = 0.1
    private var maximumDimmingAlpha: CGFloat = 0.5
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maximumDimmingAlpha
        return view
    }()
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        let height = min(container.preferredContentSize.height, metrics.maximumContainerHeight)
        animateContainerHeight(height)
    }
    
    var containerViewHeightConstraint: NSLayoutConstraint!
    var containerViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        install(containerViewController, on: containerView)
        NSLayoutConstraint.activate([
            
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: metrics.bufferHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: metrics.bufferHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
        let animator = UIViewPropertyAnimator(duration: 0.4, timingParameters: springTiming)
        
        animator.addAnimations {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maximumDimmingAlpha
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maximumDimmingAlpha
        
        let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
        let dimmAnimator = UIViewPropertyAnimator(duration: 0.4, timingParameters: springTiming)
        let dismissAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        
        dismissAnimator.addAnimations {
            self.containerViewBottomConstraint?.constant = 1000
            self.view.layoutIfNeeded()
        }
        dimmAnimator.addAnimations {
            self.dimmedView.alpha = 0
        }
        dimmAnimator.addCompletion { _ in
            self.dismiss(animated: false)
        }
        dimmAnimator.startAnimation()
        dismissAnimator.startAnimation()
    }
}
