//
//  TooltipView.swift
//  Blockzilla
//
//  Created by Sorin Paraipan on 16.02.2022.
//  Copyright © 2022 Mozilla. All rights reserved.
//

import UIKit

class TooltipView {
    
    let labelTextColor = UIColor(red: 251/255, green: 251/255, blue: 254/255, alpha: 1)
    let colorRight = UIColor(red: 171/255, green: 113/255, blue: 255/255, alpha: 1).cgColor
    let colorLeft = UIColor(red: 89/255, green: 42/255, blue: 203/255, alpha: 1).cgColor
    
    lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = UIScreen.main.bounds
        gradientLayer.colors = [colorLeft, colorRight]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }()
    
    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelContainerStackView, dismissButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .equalCentering
        stackView.spacing = 16
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layer.insertSublayer(gradient, at: 0)
        return stackView
    }()
    
    lazy var labelContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Metropolis-SemiBold", size: 16)
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Inter-Regular", size: 16)
        label.numberOfLines = 0
        label.textColor = labelTextColor
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.setImage(UIImage(imageLiteralResourceName: "icon_stop_menu"), for: .normal)
        return button
    }()
    
    func set(title: String = "", body: String) {
        titleLabel.text = title
        titleLabel.isHidden = title.isEmpty
        bodyLabel.text = body
    }
}
