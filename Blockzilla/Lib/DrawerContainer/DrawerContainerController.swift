//
//  DrawerContainerController.swift
//  Blockzilla
//
//  Created by Jeff Boek on 10/27/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit
import SnapKit

class DrawerContainerView: UIView {
    private class DrawerView: UIView {
        override var intrinsicContentSize: CGSize { return CGSize(width: 320, height: 0) }
    }

    private let mainContainerView = UIView(frame: .zero)
    private let drawerContainerView = DrawerView(frame: .zero)
    private var drawerConstraint: Constraint?

    init() {
        super.init(frame: .zero)
        drawerContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        drawerContainerView.backgroundColor = .yellow
        mainContainerView.backgroundColor = .purple

        addSubview(mainContainerView)
        addSubview(drawerContainerView)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        mainContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().priority(500)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().priority(500)

            make.leading.equalTo(drawerContainerView.snp.trailing)
        }

        drawerContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(320)
            make.trailing.lessThanOrEqualToSuperview().offset(-55)

            self.drawerConstraint = make.leading.equalToSuperview().constraint
            self.drawerConstraint?.activate()
        }
    }
}

class DrawerContainerController: UIViewController {
    private var drawerViewcontroller: UIViewController
    private var mainViewController: UIViewController

    init(main: UIViewController, drawer: UIViewController) {
        mainViewController = main
        drawerViewcontroller = drawer
        super.init(nibName: nil, bundle: nil)

    }

    override func loadView() {
        let view = DrawerContainerView()
        self.view = view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) not implemented")
    }

    func showDrawer() {

    }
}
