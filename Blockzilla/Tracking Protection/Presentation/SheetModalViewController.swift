/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

class SheetModalViewController: UIViewController {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
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

    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateDismissView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var closeButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "close-button")!, for: .normal)
        button.addTarget(self, action: #selector(animateDismissView), for: .touchUpInside)
        button.accessibilityIdentifier = "closeSheetButton"
        return button
    }()

    private let containerViewController: UIViewController
    private let metrics: SheetMetrics
    private let maximumDimmingAlpha: CGFloat = 0.5

    private var containerViewHeightConstraint: Constraint!
    private var containerViewBottomConstraint: Constraint!

    init(containerViewController: UIViewController, metrics: SheetMetrics = .default) {
        self.containerViewController = containerViewController
        self.metrics = metrics
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        let height = min(container.preferredContentSize.height + metrics.closeButtonSize + metrics.closeButtonInset, metrics.maximumContainerHeight)
        animateContainerHeight(height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.alignment = .trailing
        stackView.axis = .vertical
        return stackView
    }()

    func setupConstraints() {
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewHeightConstraint = make.height.equalTo(metrics.bufferHeight).constraint
            containerViewBottomConstraint = make.bottom.equalTo(self.view).offset(metrics.bufferHeight).constraint
        }

        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(containerView.safeAreaLayoutGuide)
        }
        stackView.addArrangedSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.trailing.top.equalTo(containerView.safeAreaLayoutGuide).inset(metrics.closeButtonInset)
            make.height.width.equalTo(metrics.closeButtonSize)
        }

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(view)
        view.backgroundColor = .red

        view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        install(containerViewController, on: view)
    }

    // MARK: Present and dismiss animation

    func animatePresentContainer() {
        let animator = UIViewPropertyAnimator(duration: .animationDuration, curve: .easeOut)

        animator.addAnimations {
            self.containerViewBottomConstraint.update(offset: 0)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    func animateContainerHeight(_ height: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: .animationDuration, curve: .easeOut) {
            self.containerViewHeightConstraint?.update(offset: height)
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    func animateShowDimmedView() {
        UIView.animate(withDuration: .animationDuration) {
            self.dimmedView.alpha = self.maximumDimmingAlpha
        }
    }

    @objc func animateDismissView() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dimmedView.alpha = maximumDimmingAlpha

        let springTiming = UISpringTimingParameters(dampingRatio: 0.75, initialVelocity: CGVector(dx: 0, dy: 4))
        let dimmAnimator = UIViewPropertyAnimator(duration: .animationDuration, timingParameters: springTiming)
        let dismissAnimator = UIViewPropertyAnimator(duration: .animationDuration, curve: .easeOut)

        dismissAnimator.addAnimations {
            self.containerViewBottomConstraint?.update(offset: 1000)
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

fileprivate extension TimeInterval {
    static let animationDuration: TimeInterval = 0.25
}
